module BusinessDomain
  module Harvest
    class Invoice < Base

      belongs_to :client
      has_many :invoice_messages
      has_many :invoice_category

      def self.table_name
        "harvest_invoices"
      end

######################
#      override method
######################
      def self.src_data
        return ::Harvest::Invoice
      end

      def self.filter_params
        params = {}
        params.update :parent => '/invoice'
        params.update :mapper => [[:number	,'number'],
                                  [:period_end	,'period-end'],
                                  [:tax	,'tax'],
                                  [:srv_created_at	,'created-at'],
                                  [:discount	,'discount'],
                                  [:due_at_human_format	,'due-at-human-format'],
                                  [:notes	,'notes'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:amount	,'amount'],
                                  [:client_key	,'client-key'],
                                  [:discount_amount	,'discount-amount'],
                                  [:period_start	,'period-start'],
                                  [:recurring_invoice_id	,'recurring-invoice-id'],
                                  [:due_amount	,'due-amount'],
                                  [:target_id	,'id'],
                                  [:subject	,'subject'],
                                  [:tax_amount	,'tax-amount'],
                                  [:client_id	,'client-id'],
                                  [:purchase_order	,'purchase-order'],
                                  [:tax2_amount	,'tax2-amount'],
                                  [:currency	,'currency'],
                                  [:retainer_id	,'retainer-id'],
                                  [:estimate_id	,'estimate-id'],
                                  [:issued_at	,'issued-at'],
                                  [:tax2	,'tax2'],
                                  [:due_at	,'due-at'],
                                  [:state	,'state']]
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

