module Parser
  module PivotalTracker
    class All
      include Parser::PivotalTracker::Activity

      def parse_all
        parse_activity

      end
    end
  end
end

