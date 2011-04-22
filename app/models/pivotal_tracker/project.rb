module BusinessDomain
  module PivotalTracker
    class Project < Base

      has_many :stories
      has_many :memberships
      has_many :persons, :through => :memberships

      def self.table_name
        "pt_projects"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Activity
      end

      def self.filter_params
        params = {}
        params.update :parent => '/project'
        params.update :mapper => [[:target_id ,'id'],
                                  [:name ,'name'],
                                  [:iteration_length ,'iteration_length'],
                                  [:week_start_day ,'week_start_day'],
                                  [:point_scale ,'point_scale'],
                                  [:account ,'account'],
                                  [:first_iteration_start_time ,'first_iteration_start_time'],
                                  [:current_iteration_number ,'current_iteration_number'],
                                  [:enable_tasks ,'enable_tasks'],
                                  [:velocity_scheme ,'velocity_scheme'],
                                  [:current_velocity ,'current_velocity'],
                                  [:initial_velocity ,'initial_velocity'],
                                  [:number_of_done_iterations_to_show ,'number_of_done_iterations_to_show'],
                                  [:labels ,'labels'],
                                  [:last_activity_at ,'last_activity_at'],
                                  [:allow_attachments ,'allow_attachments'],
                                  [:public ,'public'],
                                  [:use_https ,'use_https'],
                                  [:bugs_and_chores_are_estimatable ,'bugs_and_chores_are_estimatable'],
                                  [:commit_mode ,'commit_mode']]
        return params
      end
    end
  end
end

