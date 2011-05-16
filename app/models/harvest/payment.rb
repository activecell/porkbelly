module BusinessDomain
  module Harvest
    class Payment < Base

      belongs_to :invoice

      def self.table_name
        "harvest_payments"
      end

######################
#      override method
######################
      def self.src_data
        return ::Harvest::InvoicePayment
      end

      def self.filter_params
        params = {}
        params.update :parent => '/payment'
        params.update :mapper => [[:srv_created_at	,'created-at'],
                                  [:pay_pal_transaction_id	,'pay-pal-transaction-id'],
                                  [:notes	,'notes'],
                                  [:recorded_by_email	,'recorded-by-email'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:amount	,'amount'],
                                  [:invoice_id	,'invoice-id'],
                                  [:payment_gateway_id	,'payment-gateway-id'],
                                  [:authorization	,'authorization'],
                                  [:target_id	,'id'],
                                  [:recorded_by	,'recorded-by'],
                                  [:paid_at	,'paid-at']]
        params.update :key_field => :target_id
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              invoice = Invoice.find_by_target_id(o[:invoice_id])
                           
              o.update :invoice_id => invoice[:id]
              
              object = self.find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

