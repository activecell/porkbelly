module BusinessDomain
  module Harvest
    class Project < Base

      belongs_to :client
      has_many :expenses
      has_many :day_entries
      has_many :user_assignments
      has_many :users, :through => :user_assignments
      has_many :task_assignments
      has_many :tasks, :through => :task_assignments
      def self.table_name
        "harvest_projects"
      end

      ######################
      #      override method
      ######################

      def self.src_data
        return ::Harvest::Project
      end

      def self.filter_params
        params = {}
        params.update :parent =>'/project'
        params.update :mapper => [[:name ,'name'],
                                  [:over_budget_notified_at ,'over-budget-notified-at'],
                                  [:billable ,'billable'],
                                  [:srv_created_at ,'created-at'],
                                  [:earliest_record_at ,'earliest-record-at'],
                                  [:show_budget_to_all ,'show-budget-to-all'],
                                  [:code ,'code'],
                                  [:cost_budget ,'cost-budget'],
                                  [:notify_when_over_budget ,'notify-when-over-budget'],
                                  [:srv_updated_at ,'updated-at'],
                                  [:cost_budget_include_expenses ,'cost-budget-include-expenses'],
                                  [:fees ,'fees'],
                                  [:highrise_deal_id ,'highrise-deal-id'],
                                  [:latest_record_at ,'latest-record-at'],
                                  [:hourly_rate ,'hourly-rate'],
                                  [:target_id ,'id'],
                                  [:bill_by ,'bill-by'],
                                  [:client_id ,'client-id'],
                                  [:active_user_assignments_count ,'active-user-assignments-count'],
                                  [:cache_version ,'cache-version'],
                                  [:budget ,'budget'],
                                  [:over_budget_notification_percentage ,'over-budget-notification-percentage'],
                                  [:active ,'active'],
                                  [:active_task_assignments_count ,'active-task-assignments-count'],
                                  [:basecamp_id ,'basecamp-id'],
                                  [:budget_by ,'budget-by'],
                                  [:estimate ,'estimate'],
                                  [:estimate_by ,'estimate-by'],
                                  [:notes ,'notes'],
                                  [:hint_earliest_record_at ,'hint-earliest-record-at'],
                                  [:hint_latest_record_at ,'hint-latest-record-at']]
        params.update :key_field => :target_id
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              client = Client.find_by_target_id(o[:client_id])
              o.update :client_id => client[:id]
              object = self.find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

