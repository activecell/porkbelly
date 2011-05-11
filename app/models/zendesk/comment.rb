module BusinessDomain
  module Zendesk
    class Comment < Base

#      has_one :ticket_comment
#      has_one :ticket, :through => :ticket_comment
#      has_many :attachment_lists
#      has_many :attachments,:through => :attachment_list

      def self.table_name
        "zendesk_comments"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Ticket
      end

      def self.filter_params
        params = {}
        params.update :parent => '/ticket/comments//comment'
        params.update :mapper => [[:author_id	,'author-id'],
                                  [:srv_created_at	,'created-at'],
                                  [:is_public	,'is-public'],
                                  [:type_ele	,'type'],
                                  [:value	,'value'],
                                  [:via_id	,'via-id']]
        params.update :key_field => :author_id
        params.update :change => [:token,:target_id]
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              o[:token] = o[:srv_created_at] + "+" + (o[:token] || '')
              object = self.find_or_initialize_by_token(o[:token])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

