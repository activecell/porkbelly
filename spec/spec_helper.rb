ENV["STAGE_ENV"] ||= "test"
require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "boot"))
require "rspec"

Rspec.configure do |c|
  c.mock_with :rspec
end

module SpecHelper
  module Util
    def self.load_fixture(fixture_file)
      file = File.join([File.dirname(__FILE__), "fixtures", fixture_file])
      data = ''
      f = File.open(file, 'r')
      f.each_line do |line|
        data << line
      end
      return data
    end
  end
end
