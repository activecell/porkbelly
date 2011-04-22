module BusinessDomain
  module PivotalTracker
    class Story_Note < Base

      belongs_to :story
      belongs_to :note

      def self.table_name
          "pt_stories_notes"
      end
#      override method
      def self.parse_all
        src_data = ::PivotalTracker::Story
        transaction do
          arr_obj = []
          src_data.find(:all).each do |o|
            arr_obj.push parse(o.content)
          end
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
                object = find_or_initialize_by_story_id_and_note_id(o[:story_id],o[:note_id])
                object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end

      protected

#      override method
      def self.parse_content(content)
        contain = []
        params = [[:story_id,'id']]
        parent = 'story'
#        get story
        contain.push Parser.parse_XML(parent,content,params)
#        get each node info
        contain.push Parser.parse_XML('story/notes//note',content,[[:note_id,'id']])
        contain[0][0][:story_id] = Story.find_by_target_id(contain[0][0][:story_id]).id
        contain[1].each do |ele|
          ele[:note_id] = Story.find_by_target_id(ele[:note_id]).id
          ele[:story_id] = contain[0][0][:story_id]
        end
        contain[1]
      end
    end
  end
end
