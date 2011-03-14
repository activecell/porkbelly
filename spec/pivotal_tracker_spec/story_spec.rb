require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::PivotalTracker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @token = "b496be86ae795917cb5cf375606afaac"
    @all = ::Fetcher::PivotalTracker::All.new(@token)
  end
  
  describe "::Story: stories fetcher" do
    describe "fetch_stories(token, params)" do
      before (:each) do
        @xml = ::Pivotal::Util.load_fixture("stories")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all project's stories" do
        project_id = 111
        url = @all.combine_url(@all.get_api_url('stories'))        
        url = @all.format_project_url(url, project_id)
        
        # Get last update time.
        target = "Story"
        tracking = ::SiteTracking.find_or_initialize_by_site_and_target(
          ::Fetcher::PivotalTracker::Base::SITE, target)
        
        params = {}
        if tracking and tracking.last_request
          last_request = tracking.last_request.strftime(DATE_FORMAT)
          params[:modified_since] = last_request
        end
        
        @all.stub_chain(:create_request).with(@token, url, params).and_return(@client)
        
        result = @all.fetch_stories(@token, {:project_id => project_id})
        puts "===== Current URL: #{@all.current_url} ====="
        puts "===== Stories result: #{result} ====="
        
        r1 = ::PivotalTracker::Story.find_by_target_id('6256883')
        r2 = ::PivotalTracker::Story.find_by_target_id('6500875')
        (result.include?('6256883') && result.include?('6500875') &&
          r1 != nil && r2 != nil).should be_true
      end
    end
  end
end
