module BusinessDomain
  module PivotalTracker
    class Activity < Base



      def self.table_name
        "pt_activities"
      end

      # override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Activity
        super
      end

      protected

      # override method
      def self.parse_content(content)
        @@params = [[:target_id,'id'],
        [:version,'version'],
        [:event_type,'event_type'],
        [:occurred_at,'occurred_at'],
        [:author,'author'],
        [:project_id, 'project_id'],
        [:description,'description']]
        @@parent = '/activity'
        super(content)
      end
    end
  end
end

