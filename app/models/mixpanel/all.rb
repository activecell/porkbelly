module BusinessDomain
  module Mixpanel
    class All
      include ::BusinessDomain
      def self.parse_all
        Parser.parse_all Event, "SPEC"
        Parser.parse_all EventProperty, "SPEC"
        Parser.parse_all Funnel, "SPEC"
        Parser.parse_all FunnelStep, "SPEC"
        Parser.parse_all FunnelProperty, "SPEC"
        Parser.parse_all FunnelPropertyValue, "SPEC"
        Parser.parse_all FunnelPropertyStep, "SPEC"
#        Parser.parse_all Contact
#        Parser.parse_all Project
#        Parser.parse_all Task
      end
    end
  end
end

