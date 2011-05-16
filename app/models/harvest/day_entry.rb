module BusinessDomain
  module Harvest
    class DayEntry < Base

      belongs_to :project
      belongs_to :user
      belongs_to :task

      def self.table_name
        "harvest_day_entries"
      end

######################
#      override method
######################
      def self.src_data
        return ::Harvest::Timesheet
      end

      def self.filter_params
        params = {}
        params.update :parent => '/daily/day_entries//day_entry'
        params.update :mapper => [[:target_id	,'id'],
                                  [:spent_at	,'spent_at'],
                                  [:user_id	,'user_id'],
                                  [:client	,'client'],
                                  [:project_id	,'project_id'],
                                  [:srv_project	,'project'],
                                  [:task_id	,'task_id'],
                                  [:srv_task	,'task'],
                                  [:hours	,'hours'],
                                  [:notes	,'notes'],
                                  [:srv_created_at	,'created_at'],
                                  [:srv_updated_at	,'updated_at'],
                                  [:timer_started_at	,'timer_started_at']]
        params.update :key_field => :target_id
        params.update :change => [:for_day, :target_id]
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              project = Project.find_by_target_id(o[:project_id])
              task = Task.find_by_target_id(o[:task_id])
              user = User.find_by_target_id(o[:user_id])
              
              o.update :project_id => project[:id]
              o.update :task_id => task[:id]
              o.update :user_id => user[:id]
              
              object = self.find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

