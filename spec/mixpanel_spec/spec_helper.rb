require File.expand_path(File.join(File.dirname(__FILE__), '..', "spec_helper"))
require "fetcher"
require 'json'

module Mixpanel
  module Util
    def self.load_fixture(fixture)
      file = "mixpanel/#{fixture}.json"
      return ::SpecHelper::Util.load_fixture(file)
    end
  end
end
