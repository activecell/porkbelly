module BusinessDomain
  module PivotalTracker
    class Story_Note < Base

      def self.table_name
          "pt_stories_notes"
      end
#      override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Story
        transaction do
          arr_obj = []
          @@src_data.find(:all).each do |o|
            arr_obj.push parse(o.content)
          end
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
                object = find_or_initialize_by_story_id_and_note_id(o[:story_id],o[:note_id])
                object.update_attributes(o)
            end
          end
        end
      end

#      override method
      def self.parse_content(content)
        @@params = [[:story_id,'id'],
                    [:note_id,'note/id']]
        @@parent = 'story'
        super(content)
#        update id from database
        @@contain[0][:story_id] = Story.find_by_target_id(@@contain[0][:story_id]).id
        @@contain[0][:note_id] = Note.find_by_target_id(@@contain[0][:note_id]).id
        @@contain
      end
    end
  end
end

