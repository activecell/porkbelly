module BusinessDomain
  module Zendesk
    class TicketComment < Base

      belongs_to :ticket
      belongs_to :comment

      def self.table_name
        "zendesk_ticket_comments"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::Ticket
      end

      def self.filter_params
        params = {}
        params.update :parent => '/ticket'
        params.update :mapper => [[:arr_comment_create_at,'comments//comment']]
        params.update :change => [:ticket_id,:target_id]
        params.update :key_field => :arr_comment_create_at
        params.update :be_array => [:arr_comment_create_at,'created-at']
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              o[:arr_comment_create_at].each do |n|
                ticket = Ticket.find_by_nice_id(o[:ticket_id])
                token = n + "+" + (o[:ticket_id] || '')
                comment = Comment.find_by_token(token)
                if ticket.nil? or comment.nil?
                  next
                end
                record = {}
                record[:ticket_id] = ticket[:id].to_s
                record[:comment_id] = comment[:id].to_s
                object = find_or_initialize_by_ticket_id_and_comment_id(record[:ticket_id],record[:comment_id])
                object.update_attributes(record)
              end
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

