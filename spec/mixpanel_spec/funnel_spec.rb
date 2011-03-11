require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::Mixpanel" do
  before(:each) do
    @all = ::Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
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
end

