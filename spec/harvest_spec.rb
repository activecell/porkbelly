require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"

module Harvest
  module Util
    def self.load_fixture(fixture)
      file = File.dirname(__FILE__) + "/fixtures/harvest/" + fixture + ".xml"
      data = ''
      f = File.open(file, "r") 
      f.each_line do |line|
        data += line
      end
      return data
    end
  end
end

describe "Harvest's " do
  describe "client" do
    describe "initialize" do
      it "should raise exception if credential is invalid" do
        lambda { Fetcher::Harvest::All.new([]) }.should raise_error(ArgumentError)
        lambda { Fetcher::Harvest::All.new({}) }.should raise_error(ArgumentError)
      end

      it "should not raise exception if credential is valid" do
        Fetcher::Harvest::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      end
    end

    describe "fetch" do
      before(:each) do
        @all = Fetcher::Harvest::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      end

      it "should extract valid content and key from the response" do
        dummy_response = Harvest::Util.load_fixture("clients")

      end
    end
  end
end
