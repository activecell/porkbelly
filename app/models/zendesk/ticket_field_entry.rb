module BusinessDomain
  module Zendesk
    class TicketFieldEntry < Base

      belongs_to :ticket_field
      belongs_to :ticket

      def self.table_name
        "zendesk_ticket_field_entries"
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
        params.update :mapper => [[:arr_ticket_field_id,'ticket-field-entries//ticket-field-entry'],[:value,'ticket-field-entries//ticket-field-entry']]
        params.update :change => [:ticket_id,:target_id]
        params.update :key_field => :arr_ticket_field_id
        params.update :be_array => [[:arr_ticket_field_id,'ticket-field-id'],[:value,'value']]
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              for i in 0..(o[:arr_ticket_field_id].size-1)
                ticket = Ticket.find_by_nice_id(o[:ticket_id])
                ticket_field = TicketField.find_by_target_id(o[:arr_ticket_field_id][i])
                if ticket.nil? or ticket_field.nil?
                  next
                end
                record = {}
                record[:ticket_id] = ticket[:id].to_s
                record[:ticket_field_id] = ticket_field[:id].to_s
                record[:value] = o[:value][i]
                object = find_or_initialize_by_ticket_id_and_ticket_field_id(record[:ticket_id],record[:ticket_field_id])
                object.update_attributes(record)
              end
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

