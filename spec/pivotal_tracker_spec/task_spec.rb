require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::PivotalTracker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @token = "b496be86ae795917cb5cf375606afaac"
    @all = ::Fetcher::PivotalTracker::All.new(@token)
  end
  
  describe "::Task: story's tasks fetcher" do
    describe "fetch_tasks(token, params)" do
      before (:each) do
        @xml = ::Pivotal::Util.load_fixture("tasks")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all story's tasks" do
        project_id = 111
        story_id = 222
        url = @all.combine_url(@all.get_api_url('tasks'))        
        url = @all.format_project_url(url, project_id)
        url = @all.format_story_url(url, story_id)
        
        params = {}
        @all.stub_chain(:create_request).with(@token, url, params).and_return(@client)
        
        result = @all.fetch_tasks(@token, {:project_id => project_id, :story_id => story_id})
        puts "===== Tasks result: #{result} ====="
        
        r1 = ::PivotalTracker::Task.find_by_target_id('1')
        r2 = ::PivotalTracker::Task.find_by_target_id('2')
        (result[0] == '1' && result[1] == '2' &&
          r1 != nil && r2 != nil).should be_true
      end
    end
  end
end
