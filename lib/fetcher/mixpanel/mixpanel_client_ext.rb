require "mixpanel_client"

module Fetcher
  module Mixpanel
    # Extend Mixpanel::Client library.
    # Purpose: add some missing parameters.
    class MixpanelClientExt < ::Mixpanel::Client
      class_eval do
        OPTIONS += [:values]
        
        OPTIONS.each do |option|
          if !instance_methods.include?(option)
            class_eval "
              def #{option}(arg=nil)
                arg ? @#{option} = arg : @#{option}
              end
            "
          end
        end
      end
      
      # Config the base URI of the Mixpanel API.
      def self.set_base_uri(base_uri)
        if ::Mixpanel.const_defined?(:BASE_URI)
          ::Mixpanel.send(:remove_const, :BASE_URI)
        end
        # Set new value for BASE_URI.
        class_eval "::Mixpanel::BASE_URI = \"#{base_uri}\""
      end
      
      # Config the version of the Mixpanel API.
      def self.set_api_version(version)
        if ::Mixpanel.const_defined?(:VERSION)
          ::Mixpanel.send(:remove_const, :VERSION)
        end
        # Set new value for VERSION.
        class_eval "::Mixpanel::VERSION = \"#{version}\""
      end
    end
  end
end
