require File.expand_path("../../../initializers/database", __FILE__)
require 'cgi'
require 'uri'
require "active_support/core_ext"

module MP

=begin
  'mixpanel_events' Tables's Schema:
    id: int         int (primary key)
    content:        string
    request_url:    string
    format:         string
    credential:     string
    created_at:     datetime
    updated_at:     datetime  
=end
  class Event < ActiveRecord::Base
    before_save :format_request_url
    before_create :format_request_url
    
    def self.table_name
      "mixpanel_events"
    end
    
    def format_request_url
      self.request_url = Event.format_request_url(self.request_url)
      return true # To not interrupt the saving process.
    end
    
    # Format the parameters string before saving to DB.
    def self.format_request_url(full_url="")
      # Not save 'expire' and 'sig' params to DB, 
      # because they are always different and not important params.
      uri = URI.parse(full_url)
      
      # Parse query string to hash.
      params_hash = CGI.parse(uri.query)
      
      # Delete uncessary params.
      ["sig", "expire"].each do |key|
        params_hash.delete(key)
      end
      
      # Reset the self.params
      uri.query = params_hash.to_query.gsub("[]", '')
      return uri.to_s
    end
  end
  
  class EventProperty < ActiveRecord::Base
    def self.table_name
      "mixpanel_event_properties"
    end
  end
  
  class Funnel < ActiveRecord::Base
    def self.table_name
      "mixpanel_funnels"
    end
  end
  
  class FunnelProperty < ActiveRecord::Base
    def self.table_name
      "mixpanel_funnel_properties"
    end
  end
end
