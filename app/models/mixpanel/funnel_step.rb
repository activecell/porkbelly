require 'digest/md5'

module BusinessDomain
  module Mixpanel
    class FunnelStep < Base

      def self.table_name
        "mixpanel_funnel_steps"
      end

      ######################
      #      override method
      ######################
      def self.src_data
        return ::Mixpanel::Funnel
      end

      def self.filter_params
        params = {}
        params.update :change => [[:name,:target_id],[:token,:credential]]
        params.update :block => lambda {|content|
            object = []
            data = JSON content
            # remove root
            data = data[data.keys[0]]["data"]
            data.each do |key, value| 
              data[key]["steps"].each do |a| 
                element = {}
                element.update :at_date => key
                element.update :srv_count => a["count"].to_s
                element.update :goal => a["goal"].to_s
                element.update :overall_conv_ratio => a["overall_conv_ratio"].to_s
                element.update :step_conv_ratio => a["step_conv_ratio"].to_s
                object.push element
              end
            end
            object
          }
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              token = Digest::MD5.hexdigest(o[:name] + "+" + (o[:token] || ''))
              funnel = Funnel.find_by_token_and_at_date(token,o[:at_date])
              o.update :funnel_id => funnel[:id].to_s
              o.delete :at_date
              o.delete :name
              o.delete :token
              object = self.find_or_initialize_by_goal_and_funnel_id(o[:goal],o[:funnel_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

