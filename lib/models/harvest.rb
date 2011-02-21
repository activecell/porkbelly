require File.expand_path("../../../initializers/database", __FILE__)

module Harvest
  class Client < ActiveRecord::Base
    def self.table_name
      "harvest_clients"
    end
  end
end
