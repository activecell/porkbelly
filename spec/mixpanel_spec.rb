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

describe "Mixpanel Methods" do
  describe "Fetcher::Mixpanel::Base: base module for all Mixpanel fetchers" do
    describe "Method: existence_keys(credential) method" do
      it "should return nothing if the table is empty" do
        
      end
      
      it "should return an array of target_id if the table has data" do
        
      end
    end
    
    describe "Method: get_api_credentials(credentials_source)" do
      it "should return a hash of {:api_key => 'key', :api_secret => 'secret'} if the param is in format 'api_key:api_secret'" do
      
      end
      
      it "should return an array of hashes {:api_key => 'key', :api_secret => 'secret'} if the param is the path to CSV file (ex: mixpanel.csv)" do
      
      end
      
      it "should return empty hash if the params is ':api_key' or 'api_key:'" do
      
      end
      
      it "should raise exception if the param is an invalid string" do
      
      end
    end
    
    describe "Method: new_client(credential={})" do
      it "should create an MixpanelClientExt object with the valid api_key and api_secret" do
      
      end
      
      it "should raise error if the api_key or api_secret is missing" do
        
      end
    end
    
    describe "Method:  setup_params(params={})" do
      it "should setup default value for missing paramters" do
      
      end
    end
  end
  
  describe "Fetcher::Mixpanel::All.initialize(): constructor method" do
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
      
      it "Case 2: with params[:event]='login' --> should get only data related to that event." do
        
      end
      
      it "Case 3: with params[:event]='login' --> should get only data related to that event." do
        
      end
    end
  end
end
