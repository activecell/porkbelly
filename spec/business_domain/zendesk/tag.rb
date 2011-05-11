module BusinessDomain
  module Zendesk
    class All
      include ::BusinessDomain
      def self.parse_all
        Parser.parse_all(Organization)
        Parser.parse_all(Ticket)
        Parser.parse_all(View)
        Parser.parse_all(Comment)
        Parser.parse_all(Post)
        Parser.parse_all(Group)
        Parser.parse_all(Forum)
        Parser.parse_all(Entry)
        Parser.parse_all(TicketField)
        Parser.parse_all(Tag)
        Parser.parse_all(User)
        Parser.parse_all(Macro)
        Parser.parse_all(TicketFieldEntry)
        Parser.parse_all(TicketComment)
##        relational tables
#        Parser.parse_all(Membership)
#        Parser.parse_all(History_Track)
#        Parser.parse_all(Story_Note)
#        Parser.parse_all(Iteration_Story)
      end
    end
  end
end

