#require File.expand_path("../../base", __FILE__)
require ""

module Fetchers
  module Harvest
    module Base
      include Fetchers::Base
    end
  end
end
puts File.expand_path("../../base", __FILE__)
Fetchers::Harvest::Base.get_api_credentials("tst")
