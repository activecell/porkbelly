module BusinessDomain
  module Harvest
    class InvoiceCategory < Base

      def self.table_name
        "harvest_invoice_categories"
      end

######################
#      override method
######################
      def self.src_data
        return ::Harvest::InvoiceCategory
      end

      def self.filter_params
        params = {}
        params.update :parent => '/invoice-item-category'
        params.update :mapper => [[:name	,'name'],
                                  [:srv_created_at	,'created-at'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:use_as_expense	,'use-as-expense'],
                                  [:use_as_service	,'use-as-service'],
                                  [:target_id	,'id']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

