module BusinessDomain
  module Harvest
    class Contact < Base

      belongs_to :client

      def self.table_name
        "harvest_contacts"
      end

######################
#      override method
######################
      def self.src_data
        return ::Harvest::Contact
      end

      def self.filter_params
        params = {}
        params.update :parent => '/contact'
        params.update :mapper => [[:target_id ,'id '],
                                  [:client_id ,'client-id '],
                                  [:email ,'email '],
                                  [:first_name ,'first-name '],
                                  [:last_name ,'last-name '],
                                  [:phone_office ,'phone-office '],
                                  [:phone_mobile ,'phone-mobile '],
                                  [:fax ,'fax '],
                                  [:srv_updated_at ,'updated-at '],
                                  [:srv_created_at ,'created-at ']]
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

