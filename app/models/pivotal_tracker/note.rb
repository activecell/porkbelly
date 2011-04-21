module BusinessDomain
  module PivotalTracker
    class Note < Base

      has_one :story_note
      has_one :story, :through => :story_note

      def self.table_name
        "pt_notes"
      end

#      override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Activity
        super
      end

      protected

#      override method
      def self.parse_content(content)
        @@params = [[:target_id,'stories/story/notes/note/id'],
        [:text,'stories/story/notes/note/text'],
        [:author,'author'],
        [:noted_at,'occurred_at']]
        @@parent = 'activity'
        super(content)
        if @@contain[0][:target_id] == ''
          return nil
        end
        @@contain
      end

    end
  end
end

