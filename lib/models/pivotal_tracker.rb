require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module PivotalTracker
  # Base class for all Pivotal Tracker model classes.
  class PivotalTrackerData < ActiveRecord::Base
    
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
  class Project < PivotalTrackerData
    def self.table_name
      "pt_projects"
    end
  end
  
  class Activity < PivotalTrackerData
    def self.table_name
      "pt_activities"
    end
  end
  
  class Membership < PivotalTrackerData
    def self.table_name
      "pt_memberships"
    end
  end
  
  class Iteration < PivotalTrackerData
    def self.table_name
      "pt_iterations"
    end
  end
  
  class Story < PivotalTrackerData
    def self.table_name
      "pt_stories"
    end
  end
  
  class Note < PivotalTrackerData
    def self.table_name
      "pt_notes"
    end
  end
  
  class Task < PivotalTrackerData
    def self.table_name
      "pt_tasks"
    end
  end
end
