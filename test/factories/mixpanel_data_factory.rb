require 'rubygems'
require 'base64'
require 'json'
require 'active_support'
require 'net/http'
require 'uri'

class MixPanelDataFactory
  API_URL = "http://api.mixpanel.com/track"
  
  # A simple function for asynchronously logging to the mixpanel.com API.
  # This function requires `curl`.
  #
  # event: The overall event/category you would like to log this data under
  # properties: A hash of key-value pairs that describe the event. Must include
  # the Mixpanel API token as 'token'
  #
  # See http://mixpanel.com/api/ for further detail.
  def self.track_by_curl(event, properties={})
    if !properties.has_key?("token")
      raise "Token is required"
    end
    
    params = {"event" => event, "properties" => properties}
    data = ActiveSupport::Base64.encode64s(JSON.generate(params))
    puts "\t Params : #{data}"
    request = "#{API_URL}/?data=#{data}&test=1"
    puts "\t Request URL: #{request}"
    `curl -s '#{request}' &`
  rescue Exception => e
    puts e
    puts e.backtrace    
  end
  
  def self.track(event, properties={})
    if !properties.has_key?("token")
      raise "Token is required"
    end
    
    params = {"event" => event, "properties" => properties}
    data = ActiveSupport::Base64.encode64s(JSON.generate(params))
    puts "\t Params : #{data}"
    
    # Send request.
    url = "#{API_URL}/?data=#{data}&test=1"
    puts "\t Request URL: #{url}"
    response = send_request(url)
    puts "\t Response: #{response.body}"
    
  rescue Exception => e
    puts e
    puts e.backtrace    
  end
  
  # Send request.
  def self.send_request(uri)
    if !(uri.instance_of?(URI))
      uri = URI.parse(uri)
    end    
    return Net::HTTP.get_response(uri)
  end
end

TOKEN1 = "ef2a17494cd1210453b5b93722198250"
TOKEN2 = "108c7638882f7037e9930c9fd692330d"

EVENTS = [:show, :login, :view_page, :logout]
FUNNELS = ["View my blog"]

EVENTS.each do |e|
  puts "===> Track event: #{e}, Token: #{TOKEN1}"
  properties = {
    "token"         => TOKEN1, 
    "test_property" => "Just a test", 
    "test_time"     => Time.now.to_s,
    "gender"        => "male",
    "funnel"        => "View my blog",
    "step"          => 2,
    "goal"          => "Impression"
  }
  
  MixPanelDataFactory.track(e, properties)
  
  puts "===> Track event: #{e}, Token: #{TOKEN2}"
  properties["token"] = TOKEN2
  properties["test_time"] = Time.now.to_s
  MixPanelDataFactory.track(e, properties)
end

FUNNELS.each do |f|
  puts "===> Track funnel: #{f}, Token: #{TOKEN1}"
  properties = {
    "token"         => TOKEN1, 
    "test_property" => "Just a test", 
    "test_time"     => Time.now.to_s,
    "gender"        => "male",
    "funnel"        => f,
    "step"          => 2,
    "goal"          => "Impression"
  }
  
  MixPanelDataFactory.track(f, properties)
  
  puts "===> Track funnel: #{f}, Token: #{TOKEN2}"
  properties["token"] = TOKEN2
  properties["test_time"] = Time.now.to_s
  MixPanelDataFactory.track('mp_funnel', properties)
end
