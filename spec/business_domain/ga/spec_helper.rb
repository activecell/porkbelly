# spec_helper for Google Analytics unit test

require File.expand_path(File.join(File.dirname(__FILE__), '..','..', "spec_helper"))
require "fetcher"
require 'nokogiri'

include  ::BusinessDomain

module GA
  module Util
    def self.load_fixture(fixture)
      file = "ga/#{fixture}.xml"
      return ::SpecHelper::Util.load_fixture(file)
    end

    def self.get_fixture_path(fixture_file)
      return ::SpecHelper::Util.get_fixture_path("ga/#{fixture_file}")
    end
  end
end

DATE_FORMAT = BusinessDomain::GA::Base::DATE_TIME_FORMAT

