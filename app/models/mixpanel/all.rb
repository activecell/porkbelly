module BusinessDomain
  module Mixpanel
    class All
      include ::BusinessDomain
      def self.parse_all
        Parser.parse_all Event, "JSON"
        Parser.parse_all EventProperty, "JSON"
        Parser.parse_all Funnel, "JSON"
        Parser.parse_all FunnelStep, "JSON"
        Parser.parse_all FunnelProperty, "JSON"
        Parser.parse_all FunnelPropertyValue, "JSON"
        Parser.parse_all FunnelPropertyStep, "JSON"
#        Parser.parse_all Contact
#        Parser.parse_all Project
#        Parser.parse_all Task
      end
    end
  end
end

