require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::Mixpanel" do
  before(:each) do
    @all = ::Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
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
end

