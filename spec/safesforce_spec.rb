require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"
#require 'rubygems'
#gem 'rforce'
require 'rforce'

module Salesforce
  module Util
    def self.load_fixture(fixture)
      file = "pivotal_tracker/#{fixture}.json"
      return ::SpecHelper::Util.load_fixture(file)
    end
    
    def self.get_fixture_path(fixture_file)
      return ::SpecHelper::Util.get_fixture_path("salesforce/#{fixture_file}")
    end
  end
end

describe "Module: Fetcher::Salesforce" do
  before (:each) do
    @username = "tpl-test@gmail.com" # replace w/ your actual Salesforce developer user ID.
    @password = "tpl123456" # replace w/ your Salesforce developer account password.
    @token = "ddBclXvRGMxYopwC2d1Qe71o" # replace w/ your security token
    
    @all = Fetcher::Salesforce::All.new(@token)
  end
  
  describe "::Base: base module for all Salesforce fetchers" do
    describe "detect_server_instance(server_url)" do
      it "should set correct instance name and instance url" do
        server_url = 'https://na9-api.salesforce.com/services/Soap/u/21.0/00DE0000000HuxM'
        expected_url = 'https://na9.salesforce.com'
        expected_instance_name = 'na9'
        
        instance_url = @all.detect_server_instance(server_url)
        
        puts "=====> Instance URL: #{instance_url}"
        (instance_url == expected_url && @all.server_instance_url == expected_url &&
          @all.server_instance_name == expected_instance_name).should be_true          
      end
    end
    
    describe "config_api_version" do
      it "should get the default API Version if it has not been set in the apis.yaml file" do
        Fetcher::Salesforce::Base::SF_CONFIG['version'] = nil
        expected = Fetcher::Salesforce::Base::VERSION
        actual = @all.config_api_version
        
        puts "=====> API Version: #{actual}"
        (actual == expected).should be_true
      end
      
      it "should get the API version in the apis.yaml file" do
        Fetcher::Salesforce::Base::SF_CONFIG['version'] = '22.0'
        expected = '22.0'
        actual = @all.config_api_version
        
        puts "=====> API Version: #{actual}"
        (actual == expected).should be_true
      end
    end
    
    describe "config_login_url" do
      it "should get the default login URL if it has not been set in the apis.yaml file" do
        Fetcher::Salesforce::Base::SF_CONFIG['login_url'] = nil
        expected = Fetcher::Salesforce::Base::LOGIN_URL
        actual = @all.config_login_url
        
        puts "=====> Login URL: #{actual}"
        (actual == expected).should be_true
      end
      
      it "should get the login URL in the apis.yaml file" do
        Fetcher::Salesforce::Base::SF_CONFIG['login_url'] = "https://login.salesforce.com/"
        expected = "https://login.salesforce.com/"
        actual = @all.config_login_url
        
        puts "=====> Login URL: #{actual}"
        (actual == expected).should be_true
      end
    end
    
    describe "config_content_type" do
      it "should get the default content type format (JSON) if it has not been set in the apis.yaml file" do
        Fetcher::Salesforce::Base::SF_CONFIG['format'] = nil
        
        expected = "application/json"
        actual = @all.config_content_type
        
        puts "=====> Content type: #{actual}"
        (actual == expected).should be_true
      end
      
      it "should follow the format set in the apis.yaml file" do
        Fetcher::Salesforce::Base::SF_CONFIG['format'] = 'xml'
        
        expected = "application/xml"
        actual = @all.config_content_type
        
        puts "=====> Content type: #{actual}"
        (actual == expected).should be_true
      end
    end
    
    describe "login(username, password, token)" do
      before(:each) do
        Fetcher::Salesforce::Base::SF_CONFIG['login_url'] = nil
        Fetcher::Salesforce::Base::SF_CONFIG['format'] = nil
        
        @login_info = {:loginResponse => {
          :result=> {
            :metadataServerUrl=>"https://na9-api.salesforce.com/services/Soap/m/21.0/00DE0000000HuxM",
            :passwordExpired=>"false", 
            :sandbox=>"false", 
            :serverUrl=>"https://na9-api.salesforce.com/services/Soap/u/21.0/00DE0000000HuxM",
            :sessionId=>"00DE0000000HuxM!AQ4AQKlB2tLznkM42CGQUoZbL8oP_F6L_6eB58cUggh6yXxRptz7DsiSwgkHVQ82cqAHcpLa499LkUy4xj.5d245RxcKHwBq", 
            :userId=>"005E0000000V2jdIAC", 
            :userInfo=>{ 
              :accessibilityMode=>"false", 
              :currencySymbol=>"$", 
              :orgAttachmentFileSizeLimit=>"5242880", 
              :orgDefaultCurrencyIsoCode=>"USD",
              :orgDisallowHtmlAttachments=>"false",
              :orgHasPersonAccounts=>"false", 
              :organizationId=>"00DE0000000HuxMMAS",
              :organizationMultiCurrency=>"false", 
              :organizationName=>"TPL", 
              :profileId=>"00eE0000000VZmFIAW", 
              :roleId=>nil, 
              :sessionSecondsValid=>"7200", 
              :userDefaultCurrencyIsoCode=>nil, 
              :userEmail=>"utwkidvn@gmail.com", 
              :userFullName=>"Harry Potter", 
              :userId=>"005E0000000V2jdIAC", 
              :userLanguage=>"en_US",
              :userLocale=>"en_US",
              :userName=>"tpl-test@gmail.com",
              :userTimeZone=>"America/Los_Angeles", 
              :userType=>"Standard", 
              :userUiSkin=>"Theme3"
              }
            }
          }
        }
      end
      
      it "should login to Salesforce, get the session id, and detect server instance URL" do
        @all.login(@username, @password, @token)
        
        puts %Q{
        =====> Login result:
          session_id: #{@all.session_id}
          server_instance_url: #{@all.server_instance_url}
          server_instance_name: #{@all.server_instance_name}
        }
        (@all.session_id != nil && @all.server_instance_url != nil &&
          @all.server_instance_name != nil).should be_true
      end
    end
  end
end
