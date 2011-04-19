module BusinessDomain
  module PivotalTracker
    class All

      def parse_all
        Activity.parse_all
        Project.parse_all
      end
    end
  end
end

