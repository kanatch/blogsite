require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
Dotenv.load
require './models'

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
      end
    end
  end
  "OK" #line-bot-apiのルールで正常動作のレスポンス(なんでもいい)
end


get '/' do
    
end