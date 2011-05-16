module BusinessDomain
  module Harvest
    class UserAssignment < Base

      belongs_to :user
      belongs_to :project

      def self.table_name
        "harvest_user_assignments"
      end

      ######################
      #      override method
      ######################

      def self.src_data
        return ::Harvest::UserAssignment
      end

      def self.filter_params
        params = {}
        params.update :parent =>'/user-assignment'
        params.update :mapper => [[:srv_created_at,'created-at'],
                                  [:project_id,'project-id'],
                                  [:srv_updated_at,'updated-at'],
                                  [:hourly_rate,'hourly-rate'],
                                  [:target_id,'id'],
                                  [:user_id,'user-id'],
                                  [:deactivated,'deactivated'],
                                  [:is_project_manager,'is-project-manager'],
                                  [:budget,'budget'],
                                  [:estimate,'estimate']]
        params.update :key_field => :target_id
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              project = Project.find_by_target_id(o[:project_id])
              user = User.find_by_target_id(o[:user_id])
              
              o.update :project_id => project[:id]
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

