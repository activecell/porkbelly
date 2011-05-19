module BusinessDomain
  module Harvest
    class ExpenseCategory < Base

      has_many :expenses

      def self.table_name
        "harvest_expense_categories"
      end

      ######################
      #      override method
      ######################

      def self.src_data
        return ::Harvest::ExpenseCategory
      end

      def self.filter_params
        params = {}
        params.update :parent =>'expense-category'
        params.update :mapper => [[:name	,'name'],
                                  [:srv_created_at	,'created-at'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:target_id	,'id'],
                                  [:unit_price	,'unit-price'],
                                  [:cache_version	,'cache-version'],
                                  [:deactivated	,'deactivated'],
                                  [:unit_name	,'unit-name']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

