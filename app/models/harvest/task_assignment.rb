module BusinessDomain
  module Harvest
    class TaskAssignment < Base

      belongs_to :task
      belongs_to :project 

      def self.table_name
        "harvest_task_assignments"
      end

      ######################
      #      override method
      ######################

      def self.src_data
        return ::Harvest::TaskAssignment
      end

      def self.filter_params
        params = {}
        params.update :parent =>'/task-assignment'
        params.update :mapper => [[:billable	,'billable'],
                                  [:srv_created_at	,'created-at'],
                                  [:task_id	,'task-id'],
                                  [:project_id	,'project-id'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:hourly_rate	,'hourly-rate'],
                                  [:target_id	,'id'],
                                  [:deactivated	,'deactivated'],
                                  [:budget	,'budget'],
                                  [:estimate	,'estimate']]
        params.update :key_field => :target_id
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              project = Project.find_by_target_id(o[:project_id])
              task = Task.find_by_target_id(o[:task_id])
              
              o.update :project_id => project[:id]
              o.update :task_id => task[:id]
              
              object = self.find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

