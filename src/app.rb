require 'sinatra'
require 'sinatra/reloader'
require 'json'

# Sinatra Main controller
class MainApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    set :stat, {}
  end

  get '/' do
    "hello, world"
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = "54fc2d8735db8531e19c5181ba417826"
      config.channel_token = "VizlTDT0WdyQ8bZUBd0VKkx7HWQ601zKKCBy0yqop+x4LINs2MGcYBIOYpGe6S1M3KyNt//YSKQc0jB3hbgva8MIHZw079nYSmY512aMvgD8NHsrl8ACcNayDx/S0XHmDgCAau5jHUrWKzMxq6V6iAdB04t89/1O/w1cDnyilFU="
    }
  end
  
  post '/callback' do
    body = request.body.read
    
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
      end
      end
    }
    
    "OK"
  end
end
