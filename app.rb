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
      if mes["message"] == "panel1"
        
      end
      if mes["message"] == "panel2"
      end
      if mes["message"] == "panel3"
      end
      #全てのクライアントに送信
      # settings.sockets.each do |socket|
      #   socket.send(event.data)
      # end
      
      #受信メッセージをLINE送信
      # message = {
      #   type: 'text',
      #   text: mes["message"]
      # }
      # response = client.broadcast(message)
      # p response
      # Messages.create(message: mes["message"])
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
        puts event.message['text']
        if event.message['text'] == "マト" || event.message['text'] == "まと" || event.message['text'] == "的"
          
          settings.sockets.each do |socket|
            socket.send("pop")
          end
        
        elsif event.message['text'] == "本" || event.message['text'] == "ほん" || event.message['text'] == "ホン" || event.message['text'] == "㌿"
          
          settings.sockets.each do |socket|
            socket.send("qai")
          end
          
        elsif event.message['text'] == "らいん" || event.message['text'] == "ライン" || event.message['text'] == "LINE"
          
          settings.sockets.each do |socket|
            socket.send("trip")
          end
          
        elsif event.message['text'] == "さんぽ" || event.message['text'] == "サンポ" || event.message['text'] == "散歩" || event.message['text'] == "三歩" || event.message['text'] == "3歩"
          
          settings.sockets.each do |socket|
            socket.send("kick")
          end
          
        elsif event.message['text'] == "きょうと" || event.message['text'] == "京都" || event.message['text'] == "キョウト" || event.message['text'] == "教徒"
          
          settings.sockets.each do |socket|
            socket.send("datw")
          end
        
        elsif event.message['text'] == "きょうほん" || event.message['text'] == "キョウホン" || event.message['text'] == "教本" || event.message['text'] == "狂奔"
          
          settings.sockets.each do |socket|
            socket.send("pomad")
          end
          
        elsif event.message['text'] == "めかぶ" || event.message['text'] == "メカブ" || event.message['text'] == "雌株"
          
          settings.sockets.each do |socket|
            socket.send("lads")
          end
          
        elsif event.message['text'] == "とまと" || event.message['text'] == "トマト" || event.message['text'] == "tomato"
          
          settings.sockets.each do |socket|
            socket.send("jaff")
          end
          
        elsif event.message['text'] == "たて" || event.message['text'] == "タテ" || event.message['text'] == "盾" || event.message['text'] == "│"
          
          settings.sockets.each do |socket|
            socket.send("panic")
          end
          
        elsif event.message['text'] == "えさ" || event.message['text'] == "エサ" || event.message['text'] == "餌"
          
          settings.sockets.each do |socket|
            socket.send("gods")
          end
          
        elsif event.message['text'] == "ます" || event.message['text'] == "マス" || event.message['text'] == "升" || event.message['text'] == "鱒" || event.message['text'] == "〼"
          
          settings.sockets.each do |socket|
            socket.send("riric")
          end
          
        elsif event.message['text'] == "ぶかつ" || event.message['text'] == "部活" || event.message['text'] == "ブカツ"
          
          settings.sockets.each do |socket|
            socket.send("type")
          end
          
        elsif event.message['text'] == "こはくとう" || event.message['text'] == "琥珀糖" || event.message['text'] == "コハクトウ"
          
          settings.sockets.each do |socket|
            socket.send("dites")
          end
          
        elsif event.message['text'] == "マーク" || event.message['text'] == "まーく" || event.message['text'] == "mark" || event.message['text'] == "Mark" || event.message['text'] == "MARK"
          
          settings.sockets.each do |socket|
            socket.send("mote")
          end
          
        elsif event.message['text'] == "スポーツ" || event.message['text'] == "すぽーつ" || event.message['text'] == "sports" || event.message['text'] == "Sports" || event.message['text'] == "SPORTS"
          
          settings.sockets.each do |socket|
            socket.send("vods")
          end
          
        elsif event.message['text'] == "おう" || event.message['text'] == "オウ" || event.message['text'] == "王"
          
          settings.sockets.each do |socket|
            socket.send("lol")
          end
          
        elsif event.message['text'] == "めてお" || event.message['text'] == "メテオ" || event.message['text'] == "meteor" || event.message['text'] == "Meteor" || event.message['text'] == "METEOR"
          
          settings.sockets.each do |socket|
            socket.send("wide")
          end
          
        elsif event.message['text'] == "ライト" || event.message['text'] == "らいと" || event.message['text'] == "light" || event.message['text'] == "Light" || event.message['text'] == "LIGHT" || event.message['text'] == "とらい" || event.message['text'] == "トライ" || event.message['text'] == "try" || event.message['text'] == "Try" || event.message['text'] == "TRY"
          
          settings.sockets.each do |socket|
            socket.send("creepynuts")
          end
          
        end
        # message = {
          # type: 'text',
          # text: event.message['text']
        # }#くみたて
        # client.reply_message(event['replyToken'], message) #送信
        
        
        #dbへの登録
        # Messages.create(message: event.message['text'].to_s)
        
        # puts "開始"
        #すべてのクライアントに受け取ったメッセージを送信
        # settings.sockets.each do |socket|
        #   socket.send(event.message['text'])
        # end
        # puts "完了"
      end
    end
  end
  "OK" #line-bot-apiのルールで正常動作のレスポンス(なんでもいい)
end


get '/' do
  # if Messages.all.exists?
  #   @messages = Messages.all
  # end
  session[:point] = 0
  erb :index
end

get '/admin' do
  Messages.create(message: "わあ")
  redirect '/'
end

get '/panel/:id' do
  puts "---"
  puts session[:point]
  puts "---"
  if params[:id] == "1" || params[:id] == 1
    if session[:point] == 0 || session[:point] == 6 || session[:point] == 8 || session[:point] == 9 || session[:point] == 10 || session[:point] == 15
      session[:point] = session[:point] + 1
    else
      session[:point] = 0
    end
  elsif params[:id] == "2" || params[:id] == 2
    if session[:point] == 2 || session[:point] == 3 || session[:point] == 7 || session[:point] == 12 || session[:point] == 16 || session[:point] == 5
      session[:point] = session[:point] + 1
    elsif session[:point] == 17
      
      
      message = {
        type: 'text',
        text: "誰かがサイトの謎を解き明かした！ next.. https://kanatch.netlify.app/"
      }
      response = client.broadcast(message)
      p response
      
      
    else
      session[:point] = 0
    end
  elsif params[:id] == "3" || params[:id] == 3
    if session[:point] == 1 || session[:point] == 4 || session[:point] == 11 || session[:point] == 13 || session[:point] == 14
      session[:point] = session[:point] + 1
    else
      session[:point] = 0
    end
  end
  puts "---"
  puts session[:point]
  puts "---"
  erb :index
end