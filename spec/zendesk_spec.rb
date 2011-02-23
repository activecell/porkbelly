require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"

module Zendesk
  module Util
    def self.load_fixture(fixture)
      file = File.dirname(__FILE__) + "/fixtures/zendesk/" + fixture + ".xml"
      data = ''
      f = File.open(file, 'r')
      f.each_line do |line|
        data += line
      end
      return data
    end
  end
end

describe "Zendesk's" do
  describe "organization" do
    describe "initialize" do
      it "should raise exception if credential is invalid" do
        lambda { Fetcher::Zendesk::All.new([]) }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::All.new({}) }.should raise_error(ArgumentError)
      end
      it "should not raise exception if credential is valid" do
        Fetcher::Zendesk::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      end
    end
    describe "fetch" do 
      before(:each) do
        @all = Fetcher::Zendesk::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("organizations")
      end
    end

  end

  describe "group" do
    describe "initialize" do
      it "should raise exception if credential is invalid" do
        lambda { Fetcher::Zendesk::All.new([]) }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::All.new({}) }.should raise_error(ArgumentError)
      end
      it "should not raise exception if credential is valid" do
        Fetcher::Zendesk::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      end
    end
    describe "fetch" do 
      before(:each) do
        @all = Fetcher::Zendesk::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("groups")
      end
    end

  end
end
