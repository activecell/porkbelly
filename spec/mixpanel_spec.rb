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

describe "Module: Fetcher::Mixpanel" do
  before(:each) do
    @all = Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
  end
    
  describe "::Base: base module for all Mixpanel fetchers" do
    describe "Method: existence_keys(credential) method" do
      it "should return nothing if the table is empty" do
        api_key = "4d9b20366fda6e248d8d282946fc988a"
        
        ar_data = mock("Mock data")
        @all.stub_chain(:model_class, :where).with("credential = ?", api_key).and_return(ar_data)
             
        ar_result = mock("Query result")
        ar_data.stub!(:select).with(:target_id).and_return(ar_result)
        
        ar_result.stub!(:all).and_return([])
        
        # Call the method
        result = @all.existence_keys(api_key)
        
        (result == nil).should be_true
      end
      
      it "should return an array of target_id if the table has data" do
        api_key = "4d9b20366fda6e248d8d282946fc988a"
        
        ar_data = mock("Mock data")
        @all.stub_chain(:model_class, :where).with("credential = ?", api_key).and_return(ar_data)
             
        ar_result = mock("Query result")
        ar_data.stub!(:select).with(:target_id).and_return(ar_result)
        
        mock_entry1 = mock("Mock record 1")
        mock_entry1.stub!(:target_id).and_return("key1")
        
        returned_data = [mock_entry1]
        ar_result.stub!(:all).and_return(returned_data)
        
        
        # Call the method
        result = @all.existence_keys(api_key)
        
        result.include?("key1").should be_true
      end
    end
    
    describe "Method: get_api_credentials(credentials_source)" do
      it "should return a hash of {:api_key => 'key', :api_secret => 'secret'} if the param is in format 'api_key:api_secret'" do
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        credential = "#{api_key}:#{api_secret}"
        result = @all.get_api_credentials(credential)
        
        (result[:api_key] == api_key && result[:api_secret] == api_secret).should be_true
      end
      
      it "should return an array of hashes {:api_key => 'key', :api_secret => 'secret'} if the param is the path to CSV file (ex: mixpanel.csv)" do
        credential = "test.csv"
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        mock_result = {:api_key => api_key, :api_secret => api_secret}
        ::Helpers::Util.stub!(:hash_from_csv).with(credential).and_return([mock_result])
        
        result = @all.get_api_credentials(credential)
        
        (result[0] == mock_result).should be_true
      end
      
      it "should return empty hash if the params is ':api_key' or 'api_key:'" do
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        credential1 = "#{api_key}:"
        result1 = @all.get_api_credentials(credential1)
        
        credential2 = ":#{api_secret}"
        result2 = @all.get_api_credentials(credential2)
        
        (result1.empty? && result2.empty?).should be_true
      end
      
      it "should raise exception if the param is an invalid string" do
        credential = "abcdef"
        lambda { @all.get_api_credentials(credential) }.should raise_error
      end
    end
    
    describe "Method: new_client(credential={})" do      
      it "should create an MixpanelClientExt object with the valid api_key and api_secret" do
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        credential = {:api_key => api_key, :api_secret => api_secret}
        
        mock_client = mock("MixpanelClientExt")
        Fetcher::Mixpanel::MixpanelClientExt.stub!(:new).with('api_key' => credential[:api_key], 
                                           'api_secret' => credential[:api_secret]).and_return(mock_client)
                                           
        result = @all.new_client(credential)
        
        (result == mock_client).should be_true
      end
      
      it "should init new client with the current credential if no credential was specify in the argument" do
        mock_client = mock("MixpanelClientExt")
        Fetcher::Mixpanel::MixpanelClientExt.stub!(:new).with('api_key' => @all.credential[:api_key], 
                                           'api_secret' => @all.credential[:api_secret]).and_return(mock_client)
        result = @all.new_client
        (result == mock_client).should be_true
      end
    end
    
    describe "Method: setup_params(params={})" do
      it "should setup default value for missing parameters" do
        params = {}
        @all.setup_params(params)
        (params[:type].blank? == false).should be_true
      end
      
      it "should not set value for parameters available in the hash 'params'" do
        params = {:detect_changes => false}
        @all.setup_params(params)
        (params[:detect_changes] == false).should be_true
      end
    end
    
    describe "Method: select_params(params, keys)" do
      it "should select necessary params specified by the keys" do
        params = {:a => 1, :b => 2, :c => 3, :d => 4}
        keys = [:a, :b]
        
        expected = {:a => 1, :b => 2}
        actual = @all.select_params(params, keys)
        
        (actual.length == expected.length &&
          actual.each{|k, v| v == expected[k]}).should be_true
      end
    end
    
    describe "Method: send_request(params)" do
      it "should pass the correct block to the client.request method" do
        block = lambda{
          puts "events"
          p "['login']"
        }
        
        response = mock("Mixpanel Response")
        params = {:puts => "events", :p => "['login']"}
        @all.client.should_receive(:request).with(&block).and_return(response)
        
        # The same as above.
        #@all.client.stub!(:request).with(&block).and_return(response)
        @all.send_request(params)
      end
    end
    
    describe "Method: check_changes(data, request_url, target_id)" do
      it "should return true if data was changed" do
        request_url = "http://www.mixpanel.com/api"
        data = mock("data")
        target_id = "something"
        
        mock_events = mock("Mock table")
        @all.stub_chain(:model_class, :format_request_url).with(request_url).and_return(request_url)
        @all.stub_chain(:model_class, :where).with(
          :target_id => target_id, 
          :request_url => request_url, 
          :content => data).and_return(mock_events)
        
        mock_events.stub!(:first).and_return(nil)
        
        result = @all.check_changes(data, request_url, target_id)
        (result == true).should be_true
      end
      
      it "should return false if data was not changed" do
        request_url = "http://www.mixpanel.com/api"
        data = mock("data")
        target_id = "something"
        
        mock_events = mock("Mock table")
        @all.stub_chain(:model_class, :format_request_url).with(request_url).and_return(request_url)
        @all.stub_chain(:model_class, :where).with(
          :target_id => target_id, 
          :request_url => request_url, 
          :content => data).and_return(mock_events)
        
        mock_data = mock("Mock data")
        mock_events.stub!(:first).and_return(mock_data)
        
        result = @all.check_changes(data, request_url, target_id)
        (result == false).should be_true
      end
    end
    
    describe "Method: normalize_credential!(credential)" do
      it "should raise ArgumentError if the argument 'credential' is invalid" do
        lambda { @all.normalize_credential!("") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!("kdadbabdbkdbka:") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!(":kdadbabdbkdbka") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!("abcdef.csv") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:api_key => "dadadada"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:api_secret => "dadadada"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:test_key => "dalhdhahdkadhahd"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:api_key => "dadadada", :test_key => "dalhdhahdkadhahd"}) }.should raise_error(ArgumentError)
      end
      
      it "should return an Array or Hash if the param 'credential' is valid" do
        mock_result = {:api_key => "dadadada", :api_secret => "kdhkahdahdha"}
        result1 = @all.normalize_credential!(mock_result)
        result2 = @all.normalize_credential!("123456:abcdef")
        
        credential = "test.csv"
        @all.stub!(:get_api_credentials).with(credential).and_return([mock_result])
        result3 = @all.normalize_credential!(credential)
        
        (result1 == mock_result && 
          result2[:api_key] == "123456" && 
          result2[:api_secret] == "abcdef" &&
          result3[0] = mock_result).should be_true
      end
    end
    
    describe "Method: get_method_url(parent, method='')" do
      it "should return default API URL if the url was not found in the config file" do
        endpoint = "new_api_endpoint"
        endpoint_url = "new/api/endpoint"
        api_method = "test"
        
        Fetcher::Mixpanel::Base::MIXPANEL_CONFIG['apis'] = {}
        Fetcher::Mixpanel::Base::DEFAULT_API_URLS[endpoint] = endpoint_url
        url = @all.get_method_url(endpoint, api_method)
        
        (url == "#{endpoint_url}/#{api_method}").should be_true
      end
      
      it "should return the demanded API URL if the url was found in the config file" do
        endpoint = "new_api_endpoint"
        endpoint_url = "new/api/endpoint"
        api_method = "test"
        
        Fetcher::Mixpanel::Base::MIXPANEL_CONFIG['apis'] = {}
        Fetcher::Mixpanel::Base::MIXPANEL_CONFIG['apis'][endpoint] = endpoint_url
        
        url = @all.get_method_url(endpoint, api_method)
        
        (url == "#{endpoint_url}/#{api_method}").should be_true
      end
    end
  end
  
  describe "Class: ::All: container class including other fetcher modules." do
    describe "Method: ::All.initialize(): constructor method" do
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
    
    describe "Method: fetch_all: fetch all data with bulk of credential sources" do
    
    end
    
    describe "Method: fetch_single: fetch data within a single credential source" do
    
    end
  end
  
  describe "Module: Event" do   
    describe "fetch_all_events" do
      it "Case 1: no params[:event] --> should automatically get events's names and fetch events' data" do
        # Clear table.
        ::Mixpanel::Event.delete_all
        
        raw_events = Mixpanel::Util.load_fixture("events")
        events = JSON.parse(raw_events)
        events_names = events['data']['values'].keys
        request_url = "http://www.mixpanel.com/?test=1"
        
        @all.stub!(:fetch_event_names).and_return(events_names)
        
        @all.stub_chain(:client, :request).and_return(events)
        
        # Should insert the real DB?
        #@all.stub_chain(:model_class, :create!).and_return(true)

        event_name = events_names[0]
        series_data = events['data']['series']
        values_data = events['data']['values']
        event_values = values_data[event_name]              
        event_series = event_values.keys & series_data
        
        # The content of the record.
        json_data = {
          :data => {
            :series => event_series, 
            :values => {event_name => event_values}
          },
          :legend_size => 1
        }.to_json
        
        @all.stub!(:current_url).and_return(request_url)

        returned_events = @all.fetch_all_events
        
        # Verify data.
        record = @all.model_class.where([
          "request_url = ? AND target_id = ? AND content = ?", 
          request_url,  event_name, json_data]
        ).first
        
        (returned_events == events && record.content == json_data).should be_true
      end
      
      it "Case 2: with params[:event]='login' --> should get only data related to that event." do
        # Clear table.
        ::Mixpanel::Event.delete_all
        
        raw_events = Mixpanel::Util.load_fixture("events")
        events = JSON.parse(raw_events)
        events_names = events['data']['values'].keys
        request_url = "http://www.mixpanel.com/?test=1"
        
        event_name = events_names[0]
        params = {:event => event_name}
        
        @all.stub_chain(:client, :request).and_return(events)
                
        series_data = events['data']['series']
        values_data = events['data']['values']
        event_values = values_data[event_name]              
        event_series = event_values.keys & series_data
        
        # The content of the record.
        json_data = {
          :data => {
            :series => event_series, 
            :values => {event_name => event_values}
          },
          :legend_size => 1
        }.to_json
        
        @all.stub!(:current_url).and_return(request_url)

        returned_events = @all.fetch_all_events(params)
        
        # Verify data.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND content = ? AND credential = ?", 
          request_url,  event_name, json_data, @all.credential[:api_key]]
        ).all
        
        is_single = (records.length == 1)
        record = records[0]
        
        (returned_events == events && is_single && record.content == json_data).should be_true
      end
      
      it "Case 3: should insert with new data" do
        # Clear table.
        ::Mixpanel::Event.delete_all
        
        raw_events = Mixpanel::Util.load_fixture("events")
        events = JSON.parse(raw_events)
        events_names = events['data']['values'].keys
        request_url = "http://www.mixpanel.com/?test=1"
        
        @all.stub!(:fetch_event_names).and_return(events_names)
        @all.stub_chain(:client, :request).and_return(events)
        
        @all.stub!(:current_url).and_return(request_url)

        # Fill the table with data.
        returned_events = @all.fetch_all_events
        
        #---------------------------------------------------------------
        # Re-test & verify that the new event was inserted to DB.
        #---------------------------------------------------------------
        event_name = events_names[0]
        test_name = "Some test event"
        # Add a new event.
        test_event_data = events['data']['values'][event_name]
        events['data']['values'][test_name] = test_event_data        
        events_names = events['data']['values'].keys
        
        @all.stub!(:fetch_event_names).and_return(events_names)
        @all.stub_chain(:client, :request).and_return(events)
        returned_events = @all.fetch_all_events
        
        # The content of the record.
        series_data = events['data']['series']
        values_data = events['data']['values']
        event_values = values_data[test_name]              
        event_series = event_values.keys & series_data
        json_data = {
          :data => {
            :series => event_series, 
            :values => {test_name => event_values}
          },
          :legend_size => 1
        }.to_json
        
        # Verify data.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          request_url,  test_name, @all.credential[:api_key]]
        ).all        
        
        is_single = (records.length == 1)
        record = records[0]
        
        (returned_events == events && is_single && record.content == json_data).should be_true
      end
      
      it "Case 4: should update if data was changed" do
        raw_events = Mixpanel::Util.load_fixture("events")
        events = JSON.parse(raw_events)
        events_names = events['data']['values'].keys
        request_url = "http://www.mixpanel.com/?test=1"
        
        # Pick an event to test.
        event_name = events_names[0]
        events['data']['values'][event_name] = {"2011-02-14" => 12,"2011-02-21" => 4}  
        
        @all.stub!(:fetch_event_names).and_return(events_names)
        @all.stub_chain(:client, :request).and_return(events)
        
        @all.stub!(:current_url).and_return(request_url)

        # Fill the table with data.
        returned_events = @all.fetch_all_events
        
        #---------------------------------------------------------------
        # Verify that the event was updated.
        #---------------------------------------------------------------
        series_data = events['data']['series']
        values_data = events['data']['values']
        event_values = values_data[event_name]              
        event_series = event_values.keys & series_data
        
        # The content of the record.
        json_data = {
          :data => {
            :series => event_series, 
            :values => {event_name => event_values}
          },
          :legend_size => 1
        }.to_json
        
        # Verify data.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND content = ? AND credential = ?", 
          request_url,  event_name, json_data, @all.credential[:api_key]]
        ).all
        
        is_single = (records.length == 1)
        record = records[0]
        
        (returned_events == events && is_single && record.content == json_data).should be_true
      end
    end
    
    describe "fetch_event_names(params={}, save_to_db=true)" do
      before (:each) do
        @event_names = ["Event 1", "Event 2", "Event 3"]
        # Clear table.
        ::Mixpanel::Event.delete_all
        @request_url = "http://www.mixpanel.com/?test=1"
        @all.stub!(:current_url).and_return(@request_url)
      end
      
      it "should not save to DB if 'save_to_db'=false " do
        @all.stub_chain(:client, :request).and_return(@event_names)
        params = {}
        save_to_db = false
        names = @all.fetch_event_names(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  "Event 1", @all.credential[:api_key]]
        ).all
        
        (names == @event_names && records.blank?).should be_true
      end
      
      it "should save to DB if 'save_to_db'=true " do
        @all.stub_chain(:client, :request).and_return(@event_names)
        params = {}
        save_to_db = true
        names = @all.fetch_event_names(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  "Event 1", @all.credential[:api_key]]
        ).all
        
        (names == @event_names && !records.blank? && (records.first.target_id == "Event 1")).should be_true
      end
    end
    
    describe "fetch_event_retention(params={}, save_to_db=true)" do
      before (:each) do
        @event_names = ["Reten 1", "Event 2", "Event 3"]
        # Clear table.
        ::Mixpanel::Event.delete_all
        @request_url = "http://www.mixpanel.com/?test=1"
        @all.stub!(:current_url).and_return(@request_url)
        @retentions = Mixpanel::Util.load_fixture("event_retention")
      end
      
      it "should not auto fetch event names if the params[:event] is specified" do
        # intentionally pass invalid params to check the method is not called.
        @all.stub!(:fetch_event_names).with("dummy", "dummy").and_return("")
        
        params = {:event => 'test event'}
        @all.stub_chain(:client, :request).and_return(@retentions)
        data = @all.fetch_event_retention(params)
        
        # It will pass this case if run to here!
        (data == @retentions).should be_true
      end
      
      it "should not save to DB if 'save_to_db'=false " do
        @all.stub_chain(:client, :request).and_return(@retentions)
        params = {}
        save_to_db = false
        
        @all.stub!(:fetch_event_names).with(params, false).and_return(@event_names)
        data = @all.fetch_event_retention(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  @request_url, @all.credential[:api_key]]
        ).all
        
        (data == @retentions && records.blank?).should be_true
      end
      
      it "should save to DB if 'save_to_db'=true " do
        @all.stub_chain(:client, :request).and_return(@retentions)
        params = {}
        save_to_db = true
        
        @all.stub!(:fetch_event_names).with(params, false).and_return(@event_names)
        data = @all.fetch_event_retention(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  @request_url, @all.credential[:api_key]]
        ).all
        
        (data == @retentions && !records.blank?).should be_true
      end
    end
    
    describe "fetch_top_events(params={}, save_to_db=true)" do
      before (:each) do
        # Clear table.
        ::Mixpanel::Event.delete_all
        @request_url = "http://www.mixpanel.com/?test=1"
        @all.stub!(:current_url).and_return(@request_url)
        @top_events = JSON.parse(Mixpanel::Util.load_fixture("top_events"))
      end
      
      it "should not save to DB if 'save_to_db'=false " do
        @all.stub_chain(:client, :request).and_return(@top_events)
        params = {}
        save_to_db = false
        data = @all.fetch_top_events(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  "login", @all.credential[:api_key]]
        ).all
        
        (data == @top_events && records.blank?).should be_true
      end
      
      it "should save to DB if 'save_to_db'=true " do
        @all.stub_chain(:client, :request).and_return(@top_events)
        params = {}
        save_to_db = true
        data = @all.fetch_top_events(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  "login", @all.credential[:api_key]]
        ).all
        
        (data == @top_events && !records.blank? && records.first.target_id == "login").should be_true
      end
    end
  end
  
  describe "Module: EventProperty" do
    before (:each) do        
      @event_properties = JSON.parse(Mixpanel::Util.load_fixture("event_properties"))
      @top_properties = JSON.parse(Mixpanel::Util.load_fixture("event_property_top"))
      @property_values = JSON.parse(Mixpanel::Util.load_fixture("event_property_values"))
    end
      
    describe "fetch_all_properties(params={}, save_to_db=true)" do
      before (:each) do        
        @request_url = "http://www.mixpanel.com/events/properties/?test=1"
        @all.stub!(:current_url).and_return(@request_url)
      end
      
      it "should not save to DB if 'save_to_db'=false " do
        # Clear table.
        ::Mixpanel::EventProperty.delete_all
        
        params = {}
        property_names = {"test_time" => {"count" => 21}}
        save_to_db = false
        
        #expected = {
        #  :target_id => "test_time", 
        #  :request_url => @all.current_url, 
        #  :content => @event_properties
        #}
        
        @all.stub!(:fetch_top_properties).with(params, false).and_return(property_names)
        @all.stub_chain(:client, :request).and_return(@event_properties)
        
        data = @all.fetch_all_properties(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  "test_time", @all.credential[:api_key]]
        ).all
        
        (data[0][:content] == @event_properties && records.blank?).should be_true
      end
      
      it "should save to DB if 'save_to_db'=true " do
        # Clear table.
        ::Mixpanel::EventProperty.delete_all
        
        params = {}
        property_names = {"test_time" => {"count" => 21}}
        save_to_db = true
        
        @all.stub!(:fetch_top_properties).with(params, false).and_return(property_names)
        @all.stub_chain(:client, :request).and_return(@event_properties)
        
        data = @all.fetch_all_properties(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  "test_time", @all.credential[:api_key]]
        ).all
        
        (data[0][:content] == @event_properties && 
          records.first.target_id == "test_time").should be_true
      end
      
      it "should insert new record if data was not found in DB" do
        # Clear table.
        ::Mixpanel::EventProperty.delete_all
        
        params = {}
        save_to_db = true
        
        @all.stub!(:fetch_top_properties).with(params, false).and_return(@top_properties)
        @all.stub_chain(:client, :request).and_return(@event_properties)
        
        # Fill the table with data.
        data = @all.fetch_all_properties(params, save_to_db)
        
        #---------------------------------------------------------------
        # Re-test & verify that the new property was inserted to DB.
        #---------------------------------------------------------------
        
        # Pick a property's name to test.
        property_name = @top_properties.keys[0]
        test_name = "Some test property"
        
        # Add a fake top property name
        @top_properties[test_name] = @top_properties[property_name]
        
        @all.stub!(:fetch_top_properties).with(params, false).and_return(@top_properties)
        
        # Fill the table with data.
        data = @all.fetch_all_properties(params, save_to_db)
        
        # The content of the record.
        json_data = @event_properties.to_json
        
        # Verify data.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @all.current_url,  test_name, @all.credential[:api_key]]
        ).all        
        
        is_single = (records.length == 1)
        record = records[0]
        
        (is_single && record.content == json_data).should be_true
      end
      
      it "should update if data was changed" do
        params = {}
        save_to_db = true
        
        # Pick an property to test.
        property_name = @top_properties.keys[0]
        property = {property_name => @top_properties[property_name]}
        
        @event_properties['data']['series'] << "2011-03-10"
        
        property_data = @event_properties
        
        @all.stub!(:fetch_top_properties).with(params, false).and_return(property)
        @all.stub_chain(:client, :request).and_return(property_data)
        
        # Fill the table with data.
        data = @all.fetch_all_properties(params, save_to_db)
        
        #---------------------------------------------------------------
        # Verify that the property was updated.
        #---------------------------------------------------------------
        # The content of the record.
        json_data = property_data.to_json
        
        # Verify data.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND content = ? AND credential = ?", 
          @all.current_url,  property_name, json_data, @all.credential[:api_key]]
        ).all
        
        is_single = (records.length == 1)
        record = records[0]
        
        (is_single && record.content == json_data).should be_true
      end
    end
    
    describe "fetch_top_properties(params={}, save_to_db=true)" do
      before (:each) do        
        @request_url = "http://www.mixpanel.com/events/properties/top?test=1"
        @all.stub!(:current_url).and_return(@request_url)
      end
      
      it "should not save to db if 'save_to_db'=false" do
        # Clear table.
        ::Mixpanel::EventProperty.delete_all
        
        params = {}
        save_to_db = false
        
        @all.stub_chain(:client, :request).and_return(@top_properties)
        
        data = @all.fetch_top_properties(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  @top_properties.keys[0], @all.credential[:api_key]]
        ).all
        
        (data == @top_properties && records.blank?).should be_true
      end
      
      it "should save to db if 'save_to_db'=true" do
        # Clear table.
        ::Mixpanel::EventProperty.delete_all
        
        params = {}
        save_to_db = true
        
        @all.stub_chain(:client, :request).and_return(@top_properties)
        
        data = @all.fetch_top_properties(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  @top_properties.keys[0], @all.credential[:api_key]]
        ).all
        
        (data == @top_properties && 
          records.first.target_id == @top_properties.keys[0]).should be_true
      end
    end
    
    describe "fetch_top_property_values(params={}, save_to_db=true)" do
      before (:each) do        
        @request_url = "http://www.mixpanel.com/events/properties/values?test=1"
        @all.stub!(:current_url).and_return(@request_url)
      end
      
      it "should not save to db if 'save_to_db'=false" do
        # Clear table.
        ::Mixpanel::EventProperty.delete_all
        
        params = {:name => @top_properties.keys}
        @all.stub_chain(:client, :request).and_return(@property_values)
        
        save_to_db = false
        
        data = @all.fetch_top_property_values(params, save_to_db)
        
        property_name = @top_properties.keys[0]
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  property_name, @all.credential[:api_key]]
        ).all
        
        #property_data << {:target_id => property_name, 
        #    :request_url => current_url, :content => data}
            
        (data[0][:content] == @property_values && records.blank?).should be_true
      end
      
      it "should save to db if 'save_to_db'=true" do
        params = {:name => @top_properties.keys}
        @all.stub_chain(:client, :request).and_return(@property_values)
        
        save_to_db = true
        
        data = @all.fetch_top_property_values(params, save_to_db)
        
        property_name = @top_properties.keys[0]
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  property_name, @all.credential[:api_key]]
        ).all
        
        #property_data << {:target_id => property_name, 
        #    :request_url => current_url, :content => data}
            
        (data[0][:content] == @property_values && 
          records.first.target_id == property_name).should be_true
      end
    end
  end
  
  describe "Module: Funnel" do
    before (:each) do        
      @funnels = JSON.parse(Mixpanel::Util.load_fixture("funnels"))
      @funnel_names = ["Test Mixpanel API", "View my blog"]
    end
    
    describe "fetch_all_funnels(params={}, save_to_db=true)" do
      before(:each) do
        @request_url = "http://www.mixpanel.com/funnels?test=1"
        @all.stub!(:current_url).and_return(@request_url)
      end
      
      it "should not save to db if 'save_to_db'=false" do
        # Clear table.
        ::Mixpanel::Funnel.delete_all
        
        params = {}
        save_to_db = false
        
        @all.stub!(:fetch_funnel_names).with(params, false).and_return(@funnel_names)
        @all.stub_chain(:client, :request).and_return(@funnels)
        
        data = @all.fetch_all_funnels(params, save_to_db)
        
        funnel_name = @funnel_names[0]
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  funnel_name, @all.credential[:api_key]]
        ).all
        
        (data == @funnels && records.blank?).should be_true
      end
      
      it "should save to db if 'save_to_db'=true" do
        params = {}
        save_to_db = true
        
        @all.stub!(:fetch_funnel_names).with(params, false).and_return(@funnel_names)
        @all.stub_chain(:client, :request).and_return(@funnels)
        
        data = @all.fetch_all_funnels(params, save_to_db)
        
        funnel_name = @funnel_names[0]
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  funnel_name, @all.credential[:api_key]]
        ).all
        
        (data == @funnels && records.first.target_id == funnel_name).should be_true
      end
      
      it "should insert new record if data was not found in DB" do
        # Clear table.
        ::Mixpanel::Funnel.delete_all
        
        params = {}
        save_to_db = true
        
        @all.stub!(:fetch_funnel_names).with(params, false).and_return(@funnel_names)        
        @all.stub_chain(:client, :request).and_return(@funnels)
        
        # Fill the table with data.
        data = @all.fetch_all_funnels(params, save_to_db)
        
        #---------------------------------------------------------------
        # Re-test & verify that the new funnel was inserted to DB.
        #---------------------------------------------------------------
        
        # Pick a property's name to test.
        funnel_name = @funnel_names[0]
        test_name = "Some test funnel"
        @funnel_names << test_name
        
        # Add a fake top property name
        @funnels[test_name] = @funnels[funnel_name] 
        
        @all.stub!(:fetch_funnel_names).with(params, false).and_return(@funnel_names)
        @all.stub_chain(:client, :request).and_return(@funnels)
        
        # Fill the table with data.
        data = @all.fetch_all_funnels(params, save_to_db)
        
        # The content of the record.
        json_data = {test_name => @funnels[test_name]}.to_json
        
        # Verify data.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @all.current_url,  test_name, @all.credential[:api_key]]
        ).all        
        
        is_single = (records.length == 1)
        record = records[0]
        
        (is_single && record.content == json_data).should be_true
      end
      
      it "should update if data was changed" do
        params = {}
        save_to_db = true
        
        @all.stub!(:fetch_funnel_names).with(params, false).and_return(@funnel_names)        
        @all.stub_chain(:client, :request).and_return(@funnels)
        
        # Fill the table with data.
        data = @all.fetch_all_funnels(params, save_to_db)
        
        #---------------------------------------------------------------
        # Re-test & verify that the new funnel was inserted to DB.
        #---------------------------------------------------------------
        
        # Pick a property's name to test.
        funnel_name = @funnel_names[0]
        
        # Add a fake top property name
        @funnels[funnel_name]['meta']['dates'] << "2011-03-09"
        
        @all.stub_chain(:client, :request).and_return(@funnels)
        
        # Fill the table with data.
        data = @all.fetch_all_funnels(params, save_to_db)
        
        # The content of the record.
        json_data = {funnel_name => @funnels[funnel_name]}.to_json
        
        # Verify data.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @all.current_url,  funnel_name, @all.credential[:api_key]]
        ).all        
        
        is_single = (records.length == 1)
        record = records[0]
        
        (is_single && record.content == json_data).should be_true
      end
    end
    
    describe "fetch_funnel_dates(params={}, save_to_db=true)" do
      before (:each) do
        @request_url = "http://www.mixpanel.com/funnels/dates/?test=1"
        @all.stub!(:current_url).and_return(@request_url)
        @funnel_dates = JSON.parse(Mixpanel::Util.load_fixture("funnel_dates"))
        @all.stub_chain(:client, :request).and_return(@funnel_dates)
      end
      
      it "should not save funnel dates to DB if 'save_to_db'=false " do
        ::Mixpanel::Funnel.delete_all
        funnel_name = @funnel_names[0]
        params = {:funnel => funnel_name}
        save_to_db = false
        dates = @all.fetch_funnel_dates(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url, funnel_name, @all.credential[:api_key]]
        ).all
        
        (dates == @funnel_dates && records.blank?).should be_true
      end
      
      it "should save funnel dates to DB if 'save_to_db'=true " do 
        ::Mixpanel::Funnel.delete_all
        funnel_name = @funnel_names[0]
        params = {:funnel => funnel_name}
        save_to_db = true
        dates = @all.fetch_funnel_dates(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url, funnel_name, @all.credential[:api_key]]
        ).all
        
        puts "===== Funnels dates record: #{records}"
        (dates == @funnel_dates && !records.blank? &&
          records.first.target_id == funnel_name).should be_true
      end
    end
    
    describe "fetch_funnel_names(params={}, save_to_db=true)" do
      before (:each) do
        @request_url = "http://www.mixpanel.com/funnels/names/?test=1"
        @all.stub!(:current_url).and_return(@request_url)
        @all.stub_chain(:client, :request).and_return(@funnel_names)
      end
      
      it "should not save to DB if 'save_to_db'=false " do        
        params = {}
        save_to_db = false
        names = @all.fetch_funnel_names(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  @funnel_names[0], @all.credential[:api_key]]
        ).all
        
        (names == @funnel_names && records.blank?).should be_true
      end
      
      it "should save to DB if 'save_to_db'=true " do        
        params = {}
        save_to_db = true
        names = @all.fetch_funnel_names(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  @funnel_names[0], @all.credential[:api_key]]
        ).all
        
        (names == @funnel_names && !records.blank? && 
          records.first.target_id == @funnel_names[0]).should be_true
      end
    end
  end
  
  describe "Module: FunnelProperty" do
    before(:each) do
      @request_url = "http://www.mixpanel.com/funnels/dates/?test=1"
      @funnel_properties = JSON.parse(Mixpanel::Util.load_fixture("funnel_properties"))
      @funnel_property_names = JSON.parse(Mixpanel::Util.load_fixture("funnel_property_names"))
      @funnel_name = "Test Funnel"
    end
    
    describe "fetch_all_funnel_properties(params={}, save_to_db=true)" do
      before(:each) do
        @request_url = "http://www.mixpanel.com/funnels/properties/?test=1"
        @all.stub!(:current_url).and_return(@request_url)        
        @all.stub_chain(:client, :request).and_return(@funnel_properties)
      end
      it "should save to db if 'save_to_db'=true" do
        params = {:funnel => @funnel_name}
        
        save_to_db = true
        proper_names = [{
          :target_id => @funnel_name, 
          :request_url => @request_url, 
          :content => @funnel_property_names
        }]
        
        names = @all.stub!(:fetch_funnel_property_names).with(params, false).and_return(proper_names)
        
        property_name = @funnel_property_names.keys[0]
        
        data = @all.fetch_all_funnel_properties(params, save_to_db)
        
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  property_name, @all.credential[:api_key]]
        ).all
        
        (!records.blank? && 
          records.first.target_id == property_name).should be_true
      end
    end
    
    describe "fetch_funnel_property_names(params={}, save_to_db=true)" do
    
    end
  end
  
  describe "Class: MixpanelClientExt: extension for ::Mixpanel::Client" do
    describe "self.set_base_uri(base_uri)" do
    
    end
    
    describe "self.set_api_version(version)" do
    
    end
  end
end
