module BusinessDomain
  module Harvest
    class Task < Base

      has_many :day_entries
      has_many :task_assignments
      has_many :projects, :through => :task_assignments
      def self.table_name
        "harvest_tasks"
      end

      ######################
      #      override method
      ######################

      def self.src_data
        return ::Harvest::Task
      end

      def self.filter_params
        params = {}
        params.update :parent =>'/task'
        params.update :mapper => [[:name ,'name'],
                                  [:srv_created_at ,'created-at'],
                                  [:billable_by_default ,'billable-by-default'],
                                  [:is_default ,'is-default'],
                                  [:srv_updated_at ,'updated-at'],
                                  [:target_id ,'id'],
                                  [:cache_version ,'cache-version'],
                                  [:deactivated ,'deactivated'],
                                  [:default_hourly_rate ,'default-hourly-rate']]
        params.update :key_field => :target_id
        return params
      end

    end
  end
end

