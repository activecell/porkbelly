require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"
require 'json'

module Mixpanel
  module Util
    def self.load_fixture(fixture)
      file = "mixpanel/#{fixture}.json"
      return ::SpecHelper::Util.load_fixture(file)
    end
  end
end

describe "Mixpanel Methods " do
  describe "initialize" do
    it "should raise exception if credential is invalid" do
      lambda { Fetcher::Mixpanel::All.new([]) }.should raise_error(ArgumentError)
      lambda { Fetcher::Mixpanel::All.new({}) }.should raise_error(ArgumentError)
      lambda { Fetcher::Mixpanel::All.new("abc") }.should raise_error(ArgumentError)
      lambda { 
        Fetcher::Mixpanel::All.new({:api_key => "09c68382ae8f86cdc568e1cd4bfe58ab"}) 
      }.should raise_error(ArgumentError)
      
      lambda { 
        Fetcher::Mixpanel::All.new({:api_secret => "09c68382ae8f86cdc568e1cd4bfe58ab"}) 
      }.should raise_error(ArgumentError)
    end
    
    it "should not raise exception if credential is valid" do
      Fetcher::Mixpanel::All.new({
        :api_key => "09c68382ae8f86cdc568e1cd4bfe58ab", 
        :api_secret => "bf93660dc571137a9b8453c15ba46b79"
      })
      
      Fetcher::Mixpanel::All.new("09c68382ae8f86cdc568e1cd4bfe58ab:bf93660dc571137a9b8453c15ba46b79")
      
      csv_file = File.join([File.dirname(__FILE__), "fixtures/mixpanel/mixpanel.csv"])
      Fetcher::Mixpanel::All.new(csv_file)
    end
  end
  
  describe "test fetch methods" do
    before(:each) do
      @all = Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
    end
    
    describe "fetch_all_events" do      
      it "Case 1: no params[:event] --> should automatically get events's names and fetch events' data" do
        raw_events = Mixpanel::Util.load_fixture("events")
        events = JSON.parse(raw_events)
        events_names = events['data']['values'].keys
        
        @all.stub!(:fetch_event_names).and_return(events_names)
        
        @all.stub_chain(:client, :request).and_return(events)
        
        # Should insert the real DB?
        @all.stub_chain(:model_class).and_return(::Mixpanel::Event)
        @all.stub_chain(:model_class, :create!).and_return(true)
        
        returned_events = @all.fetch_all_events
        
        (returned_events == events).should be_true
      end
    end
  end
end
