module BusinessDomain
  module PivotalTracker
    class Story < Base

      has_many :notes

      def self.table_name
          "pt_stories"
      end

# override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Story
        super
      end

      protected

# override method
      def self.parse_content(content)
        @@params = [[:target_id,'id'],
                    [:project_id,'project_id'],
                    [:story_type,'story_type'],
                    [:url,'url'],
                    [:estimate,'estimate'],
                    [:current_state,'current_state'],
                    [:description,'description'],
                    [:name,'name'],
                    [:requested_by,'requested_by'],
                    [:owned_by,'owned_by'],
                    [:srv_created_at,'created_at'],
                    [:srv_updated_at,'updated_at'],
                    [:labels,'labels']]
        @@parent = '/story'
        super(content)
      end

    end
  end
end

