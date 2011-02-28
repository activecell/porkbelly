require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"

module Pivotal
  module Util
    def self.load_fixture(fixture)
      file = "pivotal_tracker/#{fixture}.xml"
      return ::SpecHelper::Util.load_fixture(file)
    end
  end
end


describe "Module: Fetcher::PivotalTRacker" do
  before (:each) do
    @username = "utwkidvn@gmail.com"
    @password = "tpl123456"
    @all = Fetcher::PivotalTRacker::All.new
  end
  describe "::Base: base module for all Pivotal Tracker fetchers" do
    describe "get_token(username, password)" do
      it "should return token if username and password are correct" do
        token = 
      end
    end
  end  
end
