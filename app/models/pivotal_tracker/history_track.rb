module BusinessDomain
  module PivotalTracker
    class History_Track < Base

      belongs_to :story
      belongs_to :activity

      def self.table_name
        "pt_history_tracks"
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
        params.update :mapper => [[:story_type,'stories/story/story_type'],
                                  [:estimate,'stories/story/estimate'],
                                  [:current_state,'stories/story/current_state'],
                                  [:description,'stories/story/description'],
                                  [:name,'stories/story/name'],
                                  [:requested_by,'stories/story/requested_by'],
                                  [:owned_by,'stories/story/owned_by'],
                                  [:labels,'stories/story/labels'],
                                  [:note_id,'stories/story/notes/note/id'],
                                  [:story_id,'stories/story/id'],
                                  [:activity_id,'id'],
                                  [:accepted_at,'stories/story/accepted_at']]
        params.update :key_field => :activity_id
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
            activity = Activity.find_by_target_id(o[:activity_id])
            if activity.nil?
              next
            end
            story = Story.find_or_initialize_by_target_id(o[:story_id])
            note = Note.find_by_target_id(o[:note_id])
#            mark project_id = 0 for removed stories
            story.update_attributes(:target_id => o[:story_id],
                                    :project_id => "0") if story.project_id.nil?
            o[:activity_id] = activity[:id]
            o[:story_id] = story[:id]
            o[:note_id] = note[:id] unless note.nil?
            object = find_or_initialize_by_story_id_and_activity_id(o[:story_id],o[:activity_id])
            object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

