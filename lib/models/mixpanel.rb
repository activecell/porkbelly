require File.expand_path("../../../initializers/database", __FILE__)

module MP
  class Event < ActiveRecord::Base
    def self.table_name
      "mixpanel_events"
    end
  end
end
