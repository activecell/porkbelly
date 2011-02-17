require "mixpanel_client"

# Extend Mixpanel::Client library.
# Purpose: add some missing parameters.
class MixpanelClientExt < Mixpanel::Client
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
end
