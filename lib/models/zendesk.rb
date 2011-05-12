require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module Zendesk
  class Organization < ActiveRecord::Base
    def self.table_name
      "zendesk_src_organizations"
    end
  end
  class Group < ActiveRecord::Base
    def self.table_name
      "zendesk_src_groups"
    end
  end
  class User < ActiveRecord::Base
    def self.table_name
      "zendesk_src_users"
    end
  end
  class Tag < ActiveRecord::Base
    def self.table_name
      "zendesk_src_tags"
    end
  end
  class Forum < ActiveRecord::Base
    def self.table_name
      "zendesk_src_forums"
    end
  end
  class Entry < ActiveRecord::Base
    def self.table_name
      "zendesk_src_entries"
    end
  end
  class TicketField < ActiveRecord::Base
    def self.table_name
      "zendesk_src_ticket_fields"
    end
  end
  class Macro < ActiveRecord::Base
    def self.table_name
      "zendesk_src_macros"
    end
  end
  class View < ActiveRecord::Base
    def self.table_name
      "zendesk_src_views"
    end
  end
  class Ticket < ActiveRecord::Base
    def self.table_name
      "zendesk_src_tickets"
    end
  end
  class Post < ActiveRecord::Base
    def self.table_name
      "zendesk_src_posts"
    end
  end
  class ViewTicket < ActiveRecord::Base
    def self.table_name
      "zendesk_src_view_tickets"
    end
  end  
end

