require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module Parser
  module PivotalTracker
    class PivotalTrackerData < ActiveRecord::Base

    end

    class Activity < PivotalTrackerData
      def self.table_name
        "pt_activities"
      end
    end
end

