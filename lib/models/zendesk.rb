require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module Zendesk
  class Organization < ActiveRecord::Base
    def self.table_name
      "zendesk_organizations"
    end
  end
  class Group < ActiveRecord::Base
    def self.table_name
      "zendesk_groups"
    end
  end
end
