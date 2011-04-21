module BusinessDomain
  module PivotalTracker
    class Iteration_Story < Base

      belongs_to :iteration
      belongs_to :story

      def self.table_name
        "pt_iterations_stories"
      end
#      override method
      def self.parse_all
        src_data = ::PivotalTracker::Iteration
        transaction do
          arr_obj = []
          src_data.find(:all).each do |o|
            arr_obj.push parse(o.content)
          end
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = find_or_initialize_by_story_id_and_iteration_id(o[:story_id],o[:iteration_id])
              object.update_attributes(o)
            end
          end
        end
      end

      protected

#      override method
      def self.parse_content(content)
        contain = []
        params = [[:iteration_id,'id']]
        parent = 'iteration'
#        get iteration
        contain.push Parser.parse_XML(parent,content,params)
#        get each story info
        contain.push Parser.parse_XML('iteration/stories//story',content,[[:story_id,'id']])
        contain[0][0][:iteration_id] = Iteration.find_by_target_id(contain[0][0][:iteration_id]).id
        contain[1].each do |ele|
          ele[:story_id] = Story.find_by_target_id(ele[:story_id]).id
          ele[:iteration_id] = contain[0][0][:iteration_id]
        end
        contain[1]
      end
    end
  end
end

