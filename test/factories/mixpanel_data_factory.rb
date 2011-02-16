require 'rubygems'
require 'base64'
require 'json'
require 'active_support'

class MixPanelDataFactory
  # A simple function for asynchronously logging to the mixpanel.com API.
  # This function requires `curl`.
  #
  # event: The overall event/category you would like to log this data under
  # properties: A hash of key-value pairs that describe the event. Must include
  # the Mixpanel API token as 'token'
  #
  # See http://mixpanel.com/api/ for further detail.
  def self.track(event, properties={})
    if !properties.has_key?("token")
      raise "Token is required"
    end
    params = {"event" => event, "properties" => properties}
    data = ActiveSupport::Base64.encode64s(JSON.generate(params))
    request = "http://api.mixpanel.com/track/?data=#{data}"
    `curl -s '#{request}' &`
  rescue Exception => e
    puts e
    puts e.backtrace    
  end
end

TOKEN1 = "ef2a17494cd1210453b5b93722198250"
TOKEN2 = "108c7638882f7037e9930c9fd692330d"

EVENTS = [:login, :view_page, :test_api, :logout]

EVENTS.each do |e|
  puts "Track event: #{e}, Token: #{TOKEN1}"
  MixPanelDataFactory.track(e, {"token" => TOKEN1})
  
  puts "Track event: #{e}, Token: #{TOKEN2}"
  MixPanelDataFactory.track(e, {"token" => TOKEN2})
end
