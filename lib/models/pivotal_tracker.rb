require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module PivotalTracker
  # Base class for all Pivotal Tracker model classes.
  class PivotalTrackerData < ActiveRecord::Base

  end

  class Project < PivotalTrackerData
    def self.table_name
      "pt_src_projects"
    end
  end

  class Activity < PivotalTrackerData
    def self.table_name
      "pt_src_activities"
    end
  end

  class Membership < PivotalTrackerData
    def self.table_name
      "pt_src_memberships"
    end
  end

  class Iteration < PivotalTrackerData
    def self.table_name
      "pt_src_iterations"
    end
  end

  class Story < PivotalTrackerData
    def self.table_name
      "pt_src_stories"
    end
  end

  class Note < PivotalTrackerData
    def self.table_name
      "pt_src_notes"
    end
  end

  class Task < PivotalTrackerData
    def self.table_name
      "pt_src_tasks"
    end
  end
end

