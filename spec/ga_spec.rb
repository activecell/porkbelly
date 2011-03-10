require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"
require "nokogiri"

module GA
  module Util
    def self.load_fixture(fixture)
      file = File.dirname(__FILE__) + "/fixtures/ga/" + fixture + ".xml"
      data = ''
      f = File.open(file, 'r')
      f.each_line do |line|
        data += line
      end
      puts data
      return data
    end
  end
end

describe "GA's" do
  before(:each) do
    describe "initialize" do
      it "should rais exception when credential is invalid" do
        lambda { Fetcher::GA::All.new([]) }.should raise_error(ArgumentError)
        lambda { Fetcher::GA::All.new({}) }.should raise_error(ArgumentError)
      end
      it "should not raise exception if credential is valid" do
        Fetcher::Zendesk::All.new({:username => "utwkidvn@gmail.com", :password => "utwkidvn123456", :subdomain => "tpltest"})
      end
    end
  end
  describe "account" do
    describe "fetch" do
      before(:each) do
        @all = Fetcher::GA::All.new({:username => "utwkidvn@gmail.com", :password => "utwkidvn123456", :subdomain => "tpltest"})
        @extracted_keys = Array.new
        @dummy_response = GA::Util.load_fixture("accounts")
      end
      it "should extract valid content from response" do
        dummy_response = @dummy_response
      end
      it "should raise error when extract account id with invalid parameters" do
        some_var = "argument to pass"
        lambda { Fetcher::GA::Account.extract_account_id(some_var) }.should raise_error(ArgumentError)
      end
      it "should not raise error when extract account id with valid parameters" do
        some_var = @dummy_response
        lambda { Fetcher::GA::Account.extract_account_id(some_var) }.should_not raise_error(ArgumentError)
      end
      it "should extract and return account id with integer type" do
#        @all = Fetcher::GA::All.new({:username => "utwkidvn@gmail.com", :password => "utwkidvn123456", :subdomain => "tpltest"})
        some_var = @dummy_response
        returned_value = "20775629"
        @all.extract_account_id(some_var).should eql(returned_value)
      end
    end
  end
end
