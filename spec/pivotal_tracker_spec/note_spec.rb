require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::PivotalTracker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @token = "b496be86ae795917cb5cf375606afaac"
    @all = ::Fetcher::PivotalTracker::All.new(@token)
  end
  
  describe "::Note: story's notes fetcher" do
    describe "fetch_notes(token, params)" do
      before (:each) do
        @xml = ::Pivotal::Util.load_fixture("notes")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all story's notes" do
        project_id = 111
        story_id = 222
        url = @all.combine_url(@all.get_api_url('notes'))        
        url = @all.format_project_url(url, project_id)
        url = @all.format_story_url(url, story_id)
        
        params = {}
        @all.stub_chain(:create_request).with(@token, url, params).and_return(@client)
        
        result = @all.fetch_notes(@token, {:project_id => project_id, :story_id => story_id})
        puts "===== Notes result: #{result} ====="
        
        r1 = ::PivotalTracker::Note.find_by_target_id('3092837')
        r2 = ::PivotalTracker::Note.find_by_target_id('3849657')
        (result[0] == '3092837' && result[1] == '3849657' &&
          r1 != nil && r2 != nil).should be_true
      end
    end
  end
end
