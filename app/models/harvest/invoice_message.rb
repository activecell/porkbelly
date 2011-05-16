module BusinessDomain
  module Harvest
    class InvoiceMessage < Base

      belongs_to :invoice

      def self.table_name
        "harvest_invoice_messages"
      end

######################
#      override method
######################
      def self.src_data
        return ::Harvest::InvoiceMessage
      end

      def self.filter_params
        params = {}
        params.update :parent => '/invoice-message'
        params.update :mapper => [[:sent_by_email	,'sent-by-email	'],
                                  [:srv_created_at	,'created-at	'],
                                  [:include_pay_pal_link	,'include-pay-pal-link	'],
                                  [:thank_you	,'thank-you	'],
                                  [:body	,'body	'],
                                  [:send_me_a_copy	,'send-me-a-copy	'],
                                  [:srv_updated_at	,'updated-at	'],
                                  [:invoice_id	,'invoice-id	'],
                                  [:target_id	,'id	'],
                                  [:subject	,'subject	'],
                                  [:sent_by	,'sent-by	'],
                                  [:full_recipient_list	,'full-recipient-list	']]
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

