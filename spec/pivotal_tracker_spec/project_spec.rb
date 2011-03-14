require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::PivotalTracker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @token = "b496be86ae795917cb5cf375606afaac"
    @all = ::Fetcher::PivotalTracker::All.new(@token)
  end
  
  describe "::Project: project fetcher" do
    describe "fetch_projects(token)" do
      before (:each) do
        @xml = ::Pivotal::Util.load_fixture("projects")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all projects" do
        url = @all.combine_url(@all.get_api_url('projects'))        
        
        @all.stub_chain(:create_request).with(@token, url, {}).and_return(@client)
        
        result = @all.fetch_projects(@token)
        
        r1 = ::PivotalTracker::Project.find_by_target_id('1')
        r2 = ::PivotalTracker::Project.find_by_target_id('2')
        (result[0] == '1' && result[1] == '2' && 
          r1 != nil && r2 != nil).should be_true
      end      
    end
  end
end
