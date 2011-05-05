# spec_helper for Zendesk unit test

require File.expand_path(File.join(File.dirname(__FILE__), '..','..', "spec_helper"))
require "fetcher"
require 'nokogiri'

include  ::BusinessDomain

module Zendesk
  module Util
    def self.load_fixture(fixture)
      file = "zendesk/#{fixture}.xml"
      return ::SpecHelper::Util.load_fixture(file)
    end

    def self.get_fixture_path(fixture_file)
      return ::SpecHelper::Util.get_fixture_path("zendesk/#{fixture_file}")
    end
  end
end

DATE_FORMAT = BusinessDomain::Zendesk::Base::DATE_TIME_FORMAT

