require File.dirname(__FILE__) + "/spec_helper"

describe "Module: ::Fetcher::Mixpanel" do
  before(:each) do
    @all = ::Fetcher::Mixpanel::All.new('4d9b20366fda6e248d8d282946fc988a:b58997c62b91b19fe039b017ccb6b668')
  end

  describe "Class: ::All: container class including other ::Fetcher modules." do
    describe "Method: ::All.initialize(): constructor method" do
      it "should raise exception if credential is invalid" do
        lambda { ::Fetcher::Mixpanel::All.new([]) }.should raise_error(ArgumentError)
        lambda { ::Fetcher::Mixpanel::All.new({}) }.should raise_error(ArgumentError)
        lambda { ::Fetcher::Mixpanel::All.new("abc") }.should raise_error(ArgumentError)
        lambda { 
          ::Fetcher::Mixpanel::All.new({:api_key => "09c68382ae8f86cdc568e1cd4bfe58ab"}) 
        }.should raise_error(ArgumentError)
        
        lambda { 
          ::Fetcher::Mixpanel::All.new({:api_secret => "09c68382ae8f86cdc568e1cd4bfe58ab"}) 
        }.should raise_error(ArgumentError)
      end
      
      it "should not raise exception if credential is valid" do
        ::Fetcher::Mixpanel::All.new({
          :api_key => "09c68382ae8f86cdc568e1cd4bfe58ab", 
          :api_secret => "bf93660dc571137a9b8453c15ba46b79"
        })
        
        ::Fetcher::Mixpanel::All.new("09c68382ae8f86cdc568e1cd4bfe58ab:bf93660dc571137a9b8453c15ba46b79")
        
        csv_file = File.join([File.dirname(__FILE__), "..", "fixtures/mixpanel/mixpanel.csv"])
        ::Fetcher::Mixpanel::All.new(csv_file)
      end
    end
    
    describe "Method: fetch_all: fetch all data with bulk of credential sources" do
    
    end
  end
end

