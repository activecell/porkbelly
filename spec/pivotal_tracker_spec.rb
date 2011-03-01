require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"

module Pivotal
  module Util
    def self.load_fixture(fixture)
      file = "pivotal_tracker/#{fixture}.xml"
      return ::SpecHelper::Util.load_fixture(file)
    end
    
    def self.get_fixture_path(fixture_file)
      return ::SpecHelper::Util.get_fixture_path("pivotal_tracker/#{fixture_file}")
    end
  end
end

describe "Module: Fetcher::PivotalTracker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @token = "b496be86ae795917cb5cf375606afaac"
    @all = Fetcher::PivotalTracker::All.new(@token)
  end
  
  describe "::Base: base module for all Pivotal Tracker fetchers" do
    describe "get_token(username, password)" do
      it "should return token if username and password are correct" do
        token = @all.get_token(@username, @password)
        
        (!token.blank?).should be_true
      end
    end
    
    describe "base_url" do
      it "should return default base url if the url is not set in config file" do
        Fetcher::PivotalTracker::Base::PT_CONFIG['base_url'] = nil
        (@all.base_url == Fetcher::PivotalTracker::Base::BASE_URL)
      end
      
      it "should not return default base url if the url is set in config file" do
        url = "https://www.pivotaltracker.com/api/test"
        Fetcher::PivotalTracker::Base::PT_CONFIG['base_url'] = url
        (@all.base_url == url).should be_true
      end
    end
    
    describe "encode_options(options)" do
      it "should format options as params string" do
        options = {:project_id => 123456, :story_id => 654321}
        result = '?filter=["project_id%3A123456", "story_id%3A654321"]'
        param_string = @all.encode_options(options)
        
        (result == param_string).should be_true
      end
      
      it "should return nil if options is not hash or empty" do
        param_string1 = @all.encode_options({})
        param_string2 = @all.encode_options(nil)
        
        (param_string1.blank? && param_string2.blank?).should be_true
      end
    end
    
    describe "get_api_credentials(credentials_source)" do
      it "should return hash {:token => <token>} if credential source is '<token>'" do
        result1 = @all.get_api_credentials("abcdef")
        result2 = @all.get_api_credentials(" abcdef")
        result3 = @all.get_api_credentials("abcdef  ")
        expected_result = {:token => "abcdef"}
        
        compare = lambda { |actual, expected| 
          actual[:token] == expected[:token]
        }
        
        (compare.call(result1, expected_result) && 
          compare.call(result2, expected_result) && 
          compare.call(result3, expected_result)).should be_true
      end
      
      it "should return hash {:username => <username>, :password => <password>} 
          if credential source is '<username>:<password>'" do
        result1 = @all.get_api_credentials("tester:123456")
        result2 = @all.get_api_credentials("tester :123456")
        result3 = @all.get_api_credentials(" tester : 123456  ")
        expected_result = {:username => 'tester', :password => '123456'}
        
        compare = lambda { |actual, expected| 
          ( actual[:username] == expected[:username] && 
            actual[:password] == expected[:password])
        }

        (compare.call(result1, expected_result) && 
          compare.call(result2, expected_result) && 
          compare.call(result3, expected_result)).should be_true
      end
      
      it "should return array of hashes {:token => <token>} 
          if credential source is a CSV file containing tokens" do
        token_file = Pivotal::Util.get_fixture_path('pt_token.csv')
        
        result = @all.get_api_credentials(token_file)
        
        expected_result = [
          {'token' => 'b496be86ae795917cb5cf375606afaac'},
          {'token' => 'd0f12bb1ac3d8f1867278620dda90dbb'}
        ]
        
        compare = lambda { |actual, expected|
          return false if actual.length != expected.length
          
          expected.each_with_index do |item, index|
            if !(item['token'] == actual[index]['token'])
              return false
            end
          end
          
          return true
        }
        
        (compare.call(result, expected_result)).should be_true
      end
      
      it "should return array of hashes {:username => <username>, :password => <password>} 
          if credential source is a CSV file containing username and password" do
        file = Pivotal::Util.get_fixture_path('pt_user_password.csv')
        
        result = @all.get_api_credentials(file)
        
        expected_result = [
          {'username' => 'utwkidvn@gmail.com', 'password' => 'tpl123456'},
          {'username' => 'utwkidvn1@gmail.com', 'password' => 'tpl1234567'}
        ]
        
        compare = lambda { |actual, expected|
          return false if actual.length != expected.length
          
          expected.each_with_index do |item, index|
            if (( item['username'] != actual[index]['username']) ||
                  (item['password'] != actual[index]['password']))
              return false
            end
          end
          
          return true
        }
        
        (compare.call(result, expected_result)).should be_true
      end
    end
    
    describe "normalize_credential!(credential)" do
      it "should raise ArgumentError if the argument 'credential' is invalid" do
        lambda { @all.normalize_credential!("") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!("kdadbabdbkdbka:") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!(":kdadbabdbkdbka") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:username => "dadadada"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:password => "dadadada"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:test_key => "dalhdhahdkadhahd"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:username => "dadadada", :test_key => "dalhdhahdkadhahd"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:token => ""}) }.should raise_error(ArgumentError)
      end
      
      it "should return an Array or Hash if the param 'credential' is valid" do
        expected_token = {:token => "dadadada"}
        expected_user_passwd = {:username => 'abc@gmail.com', :password => '123456'}
        
        result1 = @all.normalize_credential!(expected_token)
        result2 = @all.normalize_credential!("abc@gmail.com:123456")
        
        credential = "test.csv"
        @all.stub!(:get_api_credentials).with(credential).and_return([expected_user_passwd])
        result3 = @all.normalize_credential!(credential)
        
        (result1 == expected_token && 
          result2[:username] == "abc@gmail.com" && 
          result2[:password] == "123456" &&
          result3[0] = expected_user_passwd[:username]).should be_true
      end
    end
    
    describe "combine_url(sub_url)" do
      it "should combine correct URL" do
        Fetcher::PivotalTracker::Base::PT_CONFIG['base_url'] = nil
        expected = "#{@all.base_url}/project/122345/stories"
        result = @all.combine_url("project/122345/stories")
        
        (result == expected).should be_true
      end
    end
    
    describe "get_url(name)" do
      it "should return default URL if the URL has not been setup in the config file yet" do
        Fetcher::PivotalTracker::Base::PT_CONFIG['apis'] = {}
        url = @all.get_api_url('projects')
        default_url = Fetcher::PivotalTracker::Base::DEFAULT_API_URLS['projects']
        
        (url == default_url).should be_true
      end
      
      it "should return the URL in config file" do
        Fetcher::PivotalTracker::Base::PT_CONFIG['apis']['projects'] = "/pt/project/test"
        url = @all.get_api_url('projects')
        
        (url == "/pt/project/test").should be_true
      end
    end
  end  

  describe "::Project: project fetcher" do
    describe "def fetch_projects(token)" do
      before (:each) do
        @xml = Pivotal::Util.load_fixture("projects")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all projects" do
        url = @all.combine_url(@all.get_api_url('projects'))        
        
        @all.stub_chain(:create_request).with(@token, url, {}).and_return(@client)
        
        result = @all.fetch_projects(@token)
        (result[0] == '1' && result[1] == '2').should be_true
      end      
    end
    
    describe "fetch_activities(token, params)" do
      before (:each) do
        @xml = Pivotal::Util.load_fixture("activities")
        @response = mock("Reponse")
        @response.stub!(:body).and_return(@xml)
        @client = mock("Connection")
        @client.stub!(:get).and_return(@response)
      end
      
      it "should fetch all activities of project" do
        project_id = 111
        url = @all.combine_url(@all.get_api_url('activities'))        
        url = url.gsub('[PROJECT_ID]', project_id.to_s)
        @all.stub_chain(:create_request).with(@token, url, {}).and_return(@client)
        
        result = @all.fetch_activities(@token, {:project_id => project_id})
        
        puts "======== Fetch result: #{result} ======"
        (result[0] == '59596685' && result[1] == '59596663').should be_true
      end
    end
  end
end
