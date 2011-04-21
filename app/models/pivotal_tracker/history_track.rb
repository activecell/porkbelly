module BusinessDomain
  module PivotalTracker
    class History_Track < Base

      belongs_to :story
      belongs_to :activity

      def self.table_name
        "pt_history_tracks"
      end

#      override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Activity
        arr_obj = []
        @@src_data.find(:all).each do |o|
          arr_obj.push parse(o.content)
        end
        transaction do
          arr_obj.each do |o|
            object = find_or_initialize_by_story_id_and_activity_id(o[:story_id],o[:activity_id])
            object.update_attributes(o)
          end
        end
      end

      protected

#      override method
      def self.parse_content(content)
        params = [[:story_type,'stories/story/story_type'],
        [:estimate,'stories/story/estimate'],
        [:current_state,'stories/story/current_state'],
        [:description,'stories/story/description'],
        [:name,'stories/story/name'],
        [:requested_by,'stories/story/requested_by'],
        [:owned_by,'stories/story/owned_by'],
        [:labels,'stories/story/labels'],
        [:note_id,'stories/story/notes/note/id'],
        [:story_id,'stories/story/id'],
        [:activity_id,'id']]
        parent = 'activity'
        contain = ''
        contain = Parser.parse_XML(parent,content,params)
#        update id from database
        activity = Activity.find_by_target_id(contain[0][:activity_id])
        story = Story.find_by_target_id(contain[0][:story_id])
        note = Note.find_by_target_id(contain[0][:note_id]) if contain[0][:note_id] != ''
        contain[0][:activity_id] = activity[:id] unless activity.nil?
        contain[0][:story_id] = story[:id] unless story.nil?
        contain[0][:note_id] = note[:id] unless note.nil?
        contain[0]
      end
    end
  end
end

