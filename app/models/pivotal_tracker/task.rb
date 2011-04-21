module BusinessDomain
  module PivotalTracker
    class Task < Base
      def self.table_name
          "pt_tasks"
      end

      # override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Task
        super
      end

      protected

      # override method
      def self.parse_content(content)
        @@params = [[:target_id,'id'],
        [:description,'description'],
        [:position,'position'],
        [:complete,'complete'],
        [:srv_created_at,'created_at']]
        @@parent = '/task'
        super(content)
      end

    end
  end
end

