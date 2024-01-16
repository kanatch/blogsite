require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
Dotenv.load
require './models'
require 'faye/websocket'

use Rack::Session::Cookie,
    secret: 'set_your_secret_key'

def client
  #clientに@clientが入ってないときだけ作成して渡す
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

#クライアントの情報を :sockets に格納
set :sockets, []


get '/websocket' do
  #WebSocketのリクエストか判別
  if Faye::WebSocket.websocket?(request.env)
    #ws変数にWebSocketの情報を格納
    ws = Faye::WebSocket.new(request.env)
    
    #通信開始のトリガー
    ws.on :open do |event|
      settings.sockets << ws
    end
    
    #イベント受信のトリガー
    ws.on :message do |event|
      mes = JSON.parse(event.data)
      
      #全てのクライアントに送信
      settings.sockets.each do |socket|
        socket.send(event.data)
      end
      
      #受信メッセージをLINE送信
      message = {
        type: 'text',
        text: mes["message"]
      }
      response = client.broadcast(message)
      p response
      Messages.create(message: mes["message"])
    end
    
    #通信切断のトリガー
    ws.on :close do |event|
      #通信情報を削除して切断処理
      ws = nil
      settings.sockets.delete(ws)
    end

    ws.rack_response
    
  end
end




post '/callback' do
  body = request.body.read #送られた内容を代入
  signature = request.env['HTTP_X_LINE_SIGNATURE'] #lineからの情報か判断
  unless client.validate_signature(body, signature) #line-bot-apiの機能で判別
    error 400 do 'Bad Request' end
  end
  events = client.parse_events_from(body) #rubyで扱いやすいように変換→event配列に代入
  events.each do |event|
    if event.is_a?(Line::Bot::Event::Message) #メッセージイベントかどうか
      if event.type === Line::Bot::Event::MessageType::Text #テキストメッセージかどうか
        message = {
          type: 'text',
          text: event.message['text']
        }#くみたて
        client.reply_message(event['replyToken'], message) #送信
        
        
        #dbへの登録
        Messages.create(message: event.message['text'].to_s)
        
        puts "開始"
        #すべてのクライアントに受け取ったメッセージを送信
        settings.sockets.each do |socket|
          socket.send(event.message['text'])
        end
        puts "完了"
      end
    end
  end
  "OK" #line-bot-apiのルールで正常動作のレスポンス(なんでもいい)
end


get '/' do
  if Messages.all.exists?
    @messages = Messages.all
  end
  erb :index
end

get '/admin' do
  Messages.create(message: "わあ")
  redirect '/'
end

post '/send' do
  
  message = {
    type: 'text',
    text: params[:message]
  }
  response = client.broadcast(message)
  p response
  
  Messages.create(message: params[:message])
  
  redirect '/'
end