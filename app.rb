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

#クライアントの情報を :sockets に格納a
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


get '/' do
  erb :top
end

get '/trend' do
  erb :trend
end

post '/minecraft' do
  settings.sockets.each do |socket|
    socket.send("pomad")
  end
  "good"
end