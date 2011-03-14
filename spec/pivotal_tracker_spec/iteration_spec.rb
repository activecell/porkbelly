require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::PivotalTracker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @token = "b496be86ae795917cb5cf375606afaac"
    @all = ::Fetcher::PivotalTracker::All.new(@token)
  end
  
  describe "::Iteration: iterations fetcher" do
    describe "fetch_iterations(token, params)" do
      before (:each) do
        @xml = ::Pivotal::Util.load_fixture("iterations")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all project's iterations" do
        project_id = 111
        url = @all.combine_url(@all.get_api_url('iterations'))        
        url = @all.format_project_url(url, project_id)
        
        params = {}
        @all.stub_chain(:create_request).with(@token, url, params).and_return(@client)
        
        result = @all.fetch_iterations(@token, {:project_id => project_id})
        puts "===== Iterations result: #{result} ====="
        
        r1 = ::PivotalTracker::Iteration.find_by_target_id('1')
        r2 = ::PivotalTracker::Iteration.find_by_target_id('2')
        (result.include?('1') && result.include?('2') &&
          r1 != nil && r2 != nil).should be_true
      end
    end
  end
end
