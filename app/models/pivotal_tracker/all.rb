module BusinessDomain
  module PivotalTracker
    class All
# FIXME: when note or story is deteled, data will be complex

      def parse_all
        Parser.parse_all(Project)
        Parser.parse_all(Story)
        Parser.parse_all(Activity)

#        Iteration.parse_all
#        Note.parse_all
#        Task.parse_all
#        Person.parse_all

##        relational tables
#        Membership.parse_all
#        History_Track.parse_all
#        Story_Note.parse_all
#        Iteration_Story.parse_all
      end
    end
  end
end

