module BusinessDomain
  module PivotalTracker
    class All

      def parse_all
        Parser.parse_all(Project)
        Parser.parse_all(Story)
        Parser.parse_all(Activity)
        Parser.parse_all(Iteration)
        Parser.parse_all(Note)
        Parser.parse_all(Task)
        Parser.parse_all(Person)

#        relational tables
        Parser.parse_all(Membership)
        Parser.parse_all(History_Track)
        Parser.parse_all(Story_Note)
        Parser.parse_all(Iteration_Story)
      end
    end
  end
end

