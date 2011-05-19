# spec_helper for Mixpanel unit test

require File.expand_path(File.join(File.dirname(__FILE__), '..','..', "spec_helper"))
require "fetcher"
require 'nokogiri'

include  ::BusinessDomain

module Mixpanel
  module Util
    def self.load_fixture(fixture)
      file = "mixpanel/#{fixture}.json"
      return ::SpecHelper::Util.load_fixture(file)
    end

    def self.get_fixture_path(fixture_file)
      return ::SpecHelper::Util.get_fixture_path("mixpanel/#{fixture_file}")
    end
  end
end

DATE_FORMAT = BusinessDomain::Mixpanel::Base::DATE_TIME_FORMAT

