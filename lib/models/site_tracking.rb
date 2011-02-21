require File.expand_path("../../../initializers/database", __FILE__)

class SiteTracking < ActiveRecord::Base
  def self.table_name
    "site_tracking"
  end
end
