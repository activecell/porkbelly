module BusinessDomain
  module PivotalTracker
    class Iteration_Story < Base

      belongs_to :iteration
      belongs_to :story

      def self.table_name
        "pt_iterations_stories"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Iteration
      end

      def self.filter_params
        params = {}
        params.update :parent => '/iteration'
        params.update :mapper => [[:iteration_id,'id'],[:arr_story_id,'stories//story']]
        params.update :key_field => :iteration_id
        params.update :be_array => [:arr_story_id,'id']
        return params
      end

      def self.update_data(arr_obj)

        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              o[:arr_story_id].each do |n|
                iteration = Iteration.find_by_target_id(o[:iteration_id])
                story = Story.find_by_target_id(n)
                if iteration.nil? or story.nil?
                  next
                end
                record = {}
                record[:iteration_id] = iteration[:id].to_s
                record[:story_id] = story[:id].to_s
                object = find_or_initialize_by_iteration_id_and_story_id(record[:iteration_id],record[:story_id])
                object.update_attributes(record)
              end
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

