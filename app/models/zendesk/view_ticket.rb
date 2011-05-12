module BusinessDomain
  module Zendesk
    class ViewTicket < Base

      belongs_to :view
      belongs_to :ticket

      def self.table_name
        "zendesk_view_tickets"
      end
      
      def self.tranfer_data
        src_data = ::Zendesk::ViewTicket
        src_data.find(:all).each do |o|
          ticket = Ticket.find_by_nice_id(o[:ticket_id])
          view = View.find_by_target_id(o[:view_id])
          obj = find_or_create_by_view_id_and_ticket_id(ticket[:id].to_s,view[:id].to_s)
          obj.save
        end
      end
    end
  end
end

