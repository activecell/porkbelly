require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module GA
  class Profile < ActiveRecord::Base
    def self.table_name
      "ga_profiles"
    end
  end
end
