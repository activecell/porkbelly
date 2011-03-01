require 'logger'
require 'garb'
require "active_support/core_ext"
require 'garb'

module Fetcher
  module GA
    module Base
      include Fetcher::Base
        @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "zendesk.log"))
      def logger
        @@logger
      end

    end
  end
end
