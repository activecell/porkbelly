require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::Mixpanel" do
  before(:each) do
    @all = ::Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
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
end

