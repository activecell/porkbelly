require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"
require "rexml/document"

module Zendesk
  module Util
    include REXML
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("organizations")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("organizations")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("groups")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("organizations")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
      end
    end
  end

  describe "user" do
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("users")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("users")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
      end
    end
  end

  describe "forum" do
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("forums")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("forums")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
      end
    end
  end

  describe "macro" do
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("macros")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("macros")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
      end
    end
  end

  describe "ticket field" do
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("ticket_fields")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("ticket_fields")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
      end
    end
  end

  describe "tag" do
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("tags")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("tags")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
      end
    end
  end

  describe "entry" do
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
        @extracted_keys = Array.new
        @dummy_response = Zendesk::Util.load_fixture("entries")
      end
      it "should extract valid content and key from the response" do
        dummy_response = Zendesk::Util.load_fixture("entries")
      end
      it "should raise error when extract_content_keys receive wrong arguments" do
        some_var = "argument to pass"
        lambda { Fetcher::Zendesk::Base.extract_content_keys() }.should raise_error(ArgumentError)
        lambda { Fetcher::Zendesk::Base.extract_content_keys(some_var) }.should raise_error(ArgumentError)
      end
      it "should extract keys and return a valid array type from response" do
        lambda { Fetcher::Zendesk::Base.extract_content_keys(@dummy_response) }.should_not raise_error(ArgumentError)
        @all.stub!(:extract_content_keys).with(@dummy_response).and_return(@extracted_keys)
      end
    end
  end
end
