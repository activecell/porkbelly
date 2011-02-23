require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

class SiteTracking < ActiveRecord::Base
  def self.table_name
    "site_trackings"
  end
end
