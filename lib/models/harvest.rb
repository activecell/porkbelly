require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module Harvest
  class Client < ActiveRecord::Base
    def self.table_name
      "harvest_clients"
    end
  end
end
