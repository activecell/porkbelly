require File.dirname(__FILE__) + "/spec_helper"

describe "Module: Fetcher::Mixpanel" do
  before(:each) do
    @all = ::Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
  end
    
  describe "::Base: base module for all Mixpanel fetchers" do
    describe "Method: existence_keys(credential) method" do
      it "should return nothing if the table is empty" do
        api_key = "4d9b20366fda6e248d8d282946fc988a"
        
        ar_data = mock("Mock data")
        @all.stub_chain(:model_class, :where).with("credential = ?", api_key).and_return(ar_data)
             
        ar_result = mock("Query result")
        ar_data.stub!(:select).with(:target_id).and_return(ar_result)
        
        ar_result.stub!(:all).and_return([])
        
        # Call the method
        result = @all.existence_keys(api_key)
        
        (result == nil).should be_true
      end
      
      it "should return an array of target_id if the table has data" do
        api_key = "4d9b20366fda6e248d8d282946fc988a"
        
        ar_data = mock("Mock data")
        @all.stub_chain(:model_class, :where).with("credential = ?", api_key).and_return(ar_data)
             
        ar_result = mock("Query result")
        ar_data.stub!(:select).with(:target_id).and_return(ar_result)
        
        mock_entry1 = mock("Mock record 1")
        mock_entry1.stub!(:target_id).and_return("key1")
        
        returned_data = [mock_entry1]
        ar_result.stub!(:all).and_return(returned_data)
        
        
        # Call the method
        result = @all.existence_keys(api_key)
        
        result.include?("key1").should be_true
      end
    end
    
    describe "Method: get_api_credentials(credentials_source)" do
      it "should return a hash of {:api_key => 'key', :api_secret => 'secret'} if the param is in format 'api_key:api_secret'" do
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        credential = "#{api_key}:#{api_secret}"
        result = @all.get_api_credentials(credential)
        
        (result[:api_key] == api_key && result[:api_secret] == api_secret).should be_true
      end
      
      it "should return an array of hashes {:api_key => 'key', :api_secret => 'secret'} if the param is the path to CSV file (ex: mixpanel.csv)" do
        credential = "test.csv"
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        mock_result = {:api_key => api_key, :api_secret => api_secret}
        ::Helpers::Util.stub!(:hash_from_csv).with(credential).and_return([mock_result])
        
        result = @all.get_api_credentials(credential)
        
        (result[0] == mock_result).should be_true
      end
      
      it "should return empty hash if the params is ':api_key' or 'api_key:'" do
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        credential1 = "#{api_key}:"
        result1 = @all.get_api_credentials(credential1)
        
        credential2 = ":#{api_secret}"
        result2 = @all.get_api_credentials(credential2)
        
        (result1.empty? && result2.empty?).should be_true
      end
      
      it "should raise exception if the param is an invalid string" do
        credential = "abcdef"
        lambda { @all.get_api_credentials(credential) }.should raise_error
      end
    end
    
    describe "Method: new_client(credential={})" do      
      it "should create an MixpanelClientExt object with the valid api_key and api_secret" do
        api_key = '4d9b20366fda6e248d8d282946fc988a'
        api_secret = 'b58997c62b91b19fe039b017ccb6b668'
        credential = {:api_key => api_key, :api_secret => api_secret}
        
        mock_client = mock("MixpanelClientExt")
        ::Fetcher::Mixpanel::MixpanelClientExt.stub!(:new).with('api_key' => credential[:api_key], 
                                           'api_secret' => credential[:api_secret]).and_return(mock_client)
                                           
        result = @all.new_client(credential)
        
        (result == mock_client).should be_true
      end
      
      it "should init new client with the current credential if no credential was specify in the argument" do
        mock_client = mock("MixpanelClientExt")
        ::Fetcher::Mixpanel::MixpanelClientExt.stub!(:new).with('api_key' => @all.credential[:api_key], 
                                           'api_secret' => @all.credential[:api_secret]).and_return(mock_client)
        result = @all.new_client
        (result == mock_client).should be_true
      end
    end
    
    describe "Method: setup_params(params={})" do
      it "should setup default value for missing parameters" do
        params = {}
        @all.setup_params(params)
        (params[:type].blank? == false).should be_true
      end
      
      it "should not set value for parameters available in the hash 'params'" do
        params = {:detect_changes => false}
        @all.setup_params(params)
        (params[:detect_changes] == false).should be_true
      end
    end
    
    describe "Method: select_params(params, keys)" do
      it "should select necessary params specified by the keys" do
        params = {:a => 1, :b => 2, :c => 3, :d => 4}
        keys = [:a, :b]
        
        expected = {:a => 1, :b => 2}
        actual = @all.select_params(params, keys)
        
        (actual.length == expected.length &&
          actual.each{|k, v| v == expected[k]}).should be_true
      end
    end
    
    describe "Method: send_request(params)" do
      it "should pass the correct block to the client.request method" do
        block = lambda{
          puts "events"
          p "['login']"
        }
        
        response = mock("Mixpanel Response")
        params = {:puts => "events", :p => "['login']"}
        @all.client.should_receive(:request).with(&block).and_return(response)
        
        # The same as above.
        #@all.client.stub!(:request).with(&block).and_return(response)
        @all.send_request(params)
      end
    end
    
    describe "Method: check_changes(data, request_url, target_id)" do
      it "should return true if data was changed" do
        request_url = "http://www.mixpanel.com/api"
        data = mock("data")
        target_id = "something"
        
        mock_events = mock("Mock table")
        @all.stub_chain(:model_class, :format_request_url).with(request_url).and_return(request_url)
        @all.stub_chain(:model_class, :where).with(
          :target_id => target_id, 
          :request_url => request_url, 
          :content => data).and_return(mock_events)
        
        mock_events.stub!(:first).and_return(nil)
        
        result = @all.check_changes(data, request_url, target_id)
        (result == true).should be_true
      end
      
      it "should return false if data was not changed" do
        request_url = "http://www.mixpanel.com/api"
        data = mock("data")
        target_id = "something"
        
        mock_events = mock("Mock table")
        @all.stub_chain(:model_class, :format_request_url).with(request_url).and_return(request_url)
        @all.stub_chain(:model_class, :where).with(
          :target_id => target_id, 
          :request_url => request_url, 
          :content => data).and_return(mock_events)
        
        mock_data = mock("Mock data")
        mock_events.stub!(:first).and_return(mock_data)
        
        result = @all.check_changes(data, request_url, target_id)
        (result == false).should be_true
      end
    end
    
    describe "Method: normalize_credential!(credential)" do
      it "should raise ArgumentError if the argument 'credential' is invalid" do
        lambda { @all.normalize_credential!("") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!("kdadbabdbkdbka:") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!(":kdadbabdbkdbka") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!("abcdef.csv") }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:api_key => "dadadada"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:api_secret => "dadadada"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:test_key => "dalhdhahdkadhahd"}) }.should raise_error(ArgumentError)
        lambda { @all.normalize_credential!({:api_key => "dadadada", :test_key => "dalhdhahdkadhahd"}) }.should raise_error(ArgumentError)
      end
      
      it "should return an Array or Hash if the param 'credential' is valid" do
        mock_result = {:api_key => "dadadada", :api_secret => "kdhkahdahdha"}
        result1 = @all.normalize_credential!(mock_result)
        result2 = @all.normalize_credential!("123456:abcdef")
        
        credential = "test.csv"
        @all.stub!(:get_api_credentials).with(credential).and_return([mock_result])
        result3 = @all.normalize_credential!(credential)
        
        (result1 == mock_result && 
          result2[:api_key] == "123456" && 
          result2[:api_secret] == "abcdef" &&
          result3[0] = mock_result).should be_true
      end
    end
    
    describe "Method: get_method_url(parent, method='')" do
      it "should return default API URL if the url was not found in the config file" do
        endpoint = "new_api_endpoint"
        endpoint_url = "new/api/endpoint"
        api_method = "test"
        
        ::Fetcher::Mixpanel::Base::MIXPANEL_CONFIG['apis'] = {}
        ::Fetcher::Mixpanel::Base::DEFAULT_API_URLS[endpoint] = endpoint_url
        url = @all.get_method_url(endpoint, api_method)
        
        (url == "#{endpoint_url}/#{api_method}").should be_true
      end
      
      it "should return the demanded API URL if the url was found in the config file" do
        endpoint = "new_api_endpoint"
        endpoint_url = "new/api/endpoint"
        api_method = "test"
        
        ::Fetcher::Mixpanel::Base::MIXPANEL_CONFIG['apis'] = {}
        ::Fetcher::Mixpanel::Base::MIXPANEL_CONFIG['apis'][endpoint] = endpoint_url
        
        url = @all.get_method_url(endpoint, api_method)
        
        (url == "#{endpoint_url}/#{api_method}").should be_true
      end
    end
  end
end

