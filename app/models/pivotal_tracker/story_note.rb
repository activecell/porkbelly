module BusinessDomain
  module PivotalTracker
    class Story_Note < Base

      belongs_to :story
      belongs_to :note

      def self.table_name
          "pt_stories_notes"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Story
      end

      def self.filter_params
        params = {}
        params.update :parent => '/story'
        params.update :mapper => [[:story_id,'id'],[:arr_note_id,'notes/note']]
        params.update :key_field => :story_id
        params.update :be_array => [:arr_note_id,'id']
        return params
      end

      def self.update_data(arr_obj)

        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              o[:arr_note_id].each do |n|
                story = Story.find_by_target_id(o[:story_id])
                note = Note.find_by_target_id(n)
                if note.nil? or story.nil?
                  next
                end
                record = {}
                record[:story_id] = story[:id]
                record[:note_id] = note[:id]
                object = find_or_initialize_by_story_id_and_note_id(record[:story_id],record[:note_id])
                object.update_attributes(record)
              end
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

