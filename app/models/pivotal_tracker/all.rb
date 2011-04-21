module BusinessDomain
  module PivotalTracker
    class All

      def parse_all
        Activity.parse_all
        Project.parse_all
        Story.parse_all
        Iteration.parse_all
        Note.parse_all
        Task.parse_all
        Person.parse_all

#        relationship tables
        Membership.parse_all
        History_Track.parse_all
        Story_Note.parse_all
        Iteration_Story.parse_all
      end
    end
  end
end

