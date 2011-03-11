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
  class User < ActiveRecord::Base
    def self.table_name
      "zendesk_users"
    end
  end
  class Tag < ActiveRecord::Base
    def self.table_name
      "zendesk_tags"
    end
  end
  class Forum < ActiveRecord::Base
    def self.table_name
      "zendesk_forums"
    end
  end
  class Entry < ActiveRecord::Base
    def self.table_name
      "zendesk_entries"
    end
  end
  class TicketField < ActiveRecord::Base
    def self.table_name
      "zendesk_ticket_fields"
    end
  end
  class Macro < ActiveRecord::Base
    def self.table_name
      "zendesk_macros"
    end
  end
end
