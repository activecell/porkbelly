require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::PivotalTracker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @token = "b496be86ae795917cb5cf375606afaac"
    @all = ::Fetcher::PivotalTracker::All.new(@token)
  end
  
  describe "::Activity: activities fetcher" do
    describe "fetch_activities(token, params)" do
      before (:each) do
        @xml = ::Pivotal::Util.load_fixture("activities")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all activities of project" do
        project_id = 111
        url = @all.combine_url(@all.get_api_url('activities'))        
        url = @all.format_project_url(url, project_id)
        
        # Get last update time.
        target = "Activity"
        tracking = ::SiteTracking.find_or_initialize_by_site_and_target(
          ::Fetcher::PivotalTracker::Base::SITE, target)
        
        params = {}
        if tracking and tracking.last_request
          last_request = tracking.last_request.strftime(DATE_FORMAT)
          params[:occurred_since_date] = last_request
        end
        
        @all.stub_chain(:create_request).with(@token, url, params).and_return(@client)
        
        result = @all.fetch_activities(@token, {:project_id => project_id})
        
        r1 = ::PivotalTracker::Activity.find_by_target_id('59596685')
        r2 = ::PivotalTracker::Activity.find_by_target_id('59596663')
        
        (result.include?('59596685') && result.include?('59596663') && 
          r1 != nil && r2 != nil).should be_true
      end
    end
  end
end
