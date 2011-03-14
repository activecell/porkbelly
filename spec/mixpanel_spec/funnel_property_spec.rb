require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::Mixpanel" do
  before(:each) do
    @all = ::Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
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
        @params = {:funnel => @funnel_name} 
        
        @proper_names = []
        @funnel_property_names.each do |k, v|
          @proper_names << {
            :target_id => k, 
            :request_url => @request_url, 
            :content => {k => v}
          }
        end
        
        @all.stub!(:fetch_funnel_property_names).with(@params, false).and_return(@proper_names)
      end
      
      it "should save to db if 'save_to_db'=true" do
        save_to_db = true
        property_name = @funnel_property_names.keys[0]

        data = @all.fetch_all_funnel_properties(@params, save_to_db)
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  property_name, @all.credential[:api_key]]
        ).all
        
        (!records.blank? && 
          records.first.target_id == property_name).should be_true
      end
      
      it "should not save to db if 'save_to_db'=false" do
        ::Mixpanel::FunnelProperty.delete_all
        save_to_db = false
        property_name = @funnel_property_names.keys[0]
        data = @all.fetch_all_funnel_properties(@params, save_to_db)
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  property_name, @all.credential[:api_key]]
        ).all
        
        (records.blank?).should be_true
      end
    end
    
    describe "fetch_funnel_property_names(params={}, save_to_db=true)" do
       before(:each) do
        @request_url = "http://www.mixpanel.com/funnels/properties/names?test=1"
        @all.stub!(:current_url).and_return(@request_url)        
        @all.stub_chain(:client, :request).and_return(@funnel_property_names)
        @params = {:funnel => @funnel_name} 
      end
      
      it "should save to db if 'save_to_db'=true" do
        save_to_db = true
        property_name = @funnel_property_names.keys[0]
        data = @all.fetch_funnel_property_names(@params, save_to_db)
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  property_name, @all.credential[:api_key]]
        ).all
        
        (!records.blank? && 
          records.first.target_id == property_name).should be_true
      end
      
      it "should not save to db if 'save_to_db'=false" do
        ::Mixpanel::FunnelProperty.delete_all
        save_to_db = false
        property_name = @funnel_property_names.keys[0]
        data = @all.fetch_funnel_property_names(@params, save_to_db)
        # Check whether the data was saved to DB.
        records = @all.model_class.where([
          "request_url = ? AND target_id = ? AND credential = ?", 
          @request_url,  property_name, @all.credential[:api_key]]
        ).all
        
        (records.blank?).should be_true
      end
    end
  end
end

