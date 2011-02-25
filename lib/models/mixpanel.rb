require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))
require 'cgi'
require 'uri'
require "active_support/core_ext"

module Mixpanel

  # Contains shared methods for Mixpanel models.
  class MixpanelData < ActiveRecord::Base
    before_save :format_request_url
    before_create :format_request_url
    
    def format_request_url
      self.request_url = self.class.format_request_url(self.request_url)
      return true # To not interrupt the saving process.
    end
    
    # Format the parameters string before saving to DB.
    def self.format_request_url(full_url="")
      # Not save 'expire' and 'sig' params to DB, 
      # because they are always different and not important params.
      uri = ::URI.parse(full_url)
      
      # Parse query string to hash.
      params_hash = ::CGI.parse(uri.query)
      
      # Delete unnecessary params.
      ["sig", "expire"].each do |key|
        params_hash.delete(key)
      end
      
      # Reset the self.params
      uri.query = params_hash.to_query.gsub("[]", '')
      return uri.to_s
    end
  end
   
=begin
  'mixpanel_events' Tables's Schema:
  id: int         int (primary key)
  target_id       string # unique ID from API services.
  content:        text
  request_url:    string
  format:         string
  credential:     string
  created_at:     datetime
  updated_at:     datetime  
=end
  class Event < MixpanelData
    def self.table_name
      "mixpanel_events"
    end
  end

=begin
  'mixpanel_event_properties' Tables's Schema:
  id: int         int (primary key)
  target_id       string # unique ID from API services.
  event_name      string # name of parent event.
  content:        text
  request_url:    string
  format:         string
  credential:     string
  created_at:     datetime
  updated_at:     datetime  
=end
  class EventProperty < MixpanelData
    def self.table_name
      "mixpanel_event_properties"
    end
  end

=begin
  'mixpanel_funnels' Tables's Schema:
  id: int         int (primary key)
  target_id       string # unique ID from API services.
  content:        text
  request_url:    string
  format:         string
  credential:     string
  created_at:     datetime
  updated_at:     datetime  
=end
  class Funnel < MixpanelData
    def self.table_name
      "mixpanel_funnels"
    end
  end

=begin
  'mixpanel_funnel_properties' Tables's Schema:
  id: int         int (primary key)
  target_id       string # unique ID from API services.
  funnel_name     string # name of parent funnel.
  content:        text
  request_url:    string
  format:         string
  credential:     string
  created_at:     datetime
  updated_at:     datetime  
=end
  class FunnelProperty < MixpanelData
    def self.table_name
      "mixpanel_funnel_properties"
    end
  end
end
