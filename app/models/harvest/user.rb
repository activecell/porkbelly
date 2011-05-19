module BusinessDomain
  module Harvest
    class User < Base

      has_many :day_entries
      has_many :expenses
      has_many :user_assignments
      has_many :assignments, :through => :assignments

      def self.table_name
        "harvest_users"
      end

      ######################
      #      override method
      ######################

      def self.src_data
        return ::Harvest::User
      end

      def self.filter_params
        params = {}
        params.update :parent =>'/user'
        params.update :mapper => [[:first_timer	,'first-timer'],
                                  [:srv_created_at	,'created-at'],
                                  [:has_access_to_all_future_projects	,'has-access-to-all-future-projects'],
                                  [:preferred_approval_screen	,'preferred-approval-screen'],
                                  [:preferred_project_status_reports_screen	,'preferred-project-status-reports-screen'],
                                  [:wants_newsletter	,'wants-newsletter'],
                                  [:twitter_username	,'twitter-username'],
                                  [:default_expense_category_id	,'default-expense-category-id'],
                                  [:default_task_id	,'default-task-id'],
                                  [:default_time_project_id	,'default-time-project-id'],
                                  [:is_contractor	,'is-contractor'],
                                  [:preferred_entry_method	,'preferred-entry-method'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:target_id	,'id'],
                                  [:timezone	,'timezone'],
                                  [:duplicate_timesheet_wants_notes	,'duplicate-timesheet-wants-notes'],
                                  [:is_admin	,'is-admin'],
                                  [:opensocial_identifier	,'opensocial-identifier'],
                                  [:cache_version	,'cache-version'],
                                  [:default_hourly_rate	,'default-hourly-rate'],
                                  [:is_active	,'is-active'],
                                  [:last_name	,'last-name'],
                                  [:wants_timesheet_duplication	,'wants-timesheet-duplication'],
                                  [:default_expense_project_id	,'default-expense-project-id'],
                                  [:email_after_submit	,'email-after-submit'],
                                  [:telephone	,'telephone'],
                                  [:department	,'department'],
                                  [:identity_url	,'identity-url'],
                                  [:email	,'email'],
                                  [:first_name	,'first-name']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

