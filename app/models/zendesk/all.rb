module BusinessDomain
  module Zendesk
    class All
      include ::BusinessDomain
      def self.parse_all
        Parser.parse_all(Organization)
        Parser.parse_all(Ticket)
        Parser.parse_all(View)
        Parser.parse_all(Comment)
#        Parser.parse_all(Activity)
#        Parser.parse_all(Iteration)
#        Parser.parse_all(Note)
#        Parser.parse_all(Task)
#        Parser.parse_all(Person)

##        relational tables
#        Parser.parse_all(Membership)
#        Parser.parse_all(History_Track)
#        Parser.parse_all(Story_Note)
#        Parser.parse_all(Iteration_Story)
      end
    end
  end
end

