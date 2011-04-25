module BusinessDomain
  module PivotalTracker
    class Note < Base

      has_one :story_note
      has_one :story, :through => :story_note

      def self.table_name
        "pt_notes"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Activity
      end

      def self.filter_params
        params = {}
        params.update :parent => '/activity'
        params.update :mapper => [[:target_id,'stories/story/notes/note/id'],
                                  [:text,'stories/story/notes/note/text'],
                                  [:author,'author'],
                                  [:noted_at,'occurred_at']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

