# spec_helper for Pivotal Tracker unit test

require File.expand_path(File.join(File.dirname(__FILE__), '..','..', "spec_helper"))
require "fetcher"
require 'nokogiri'

include  ::BusinessDomain

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

DATE_FORMAT = Fetcher::PivotalTracker::Base::DATE_TIME_FORMAT

