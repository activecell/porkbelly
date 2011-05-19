require 'digest/md5'

module BusinessDomain
  module Mixpanel
    class FunnelPropertyStep < Base

      belongs_to :funnel_property_value

      def self.table_name
        "mixpanel_funnel_property_steps"
      end

      ######################
      #      override method
      ######################
      def self.src_data
        return ::Mixpanel::FunnelProperty
      end

      def self.filter_params
        params = {}
        params.update :change => [[:funnel_property_name,:target_id],[:funnel_name,:funnel_name],[:token,:credential]]
        params.update :block => lambda {|content|
            object = []
            data = JSON content
            data.keys.each do |key|
              data[key]["values"].each do |value|
                value[1]["steps"].each do |step|
                  element = {}
                  element.update :funnel_property_id => key
                  element.update :value_name => value[0]
                  element.update :name => step[0]
                  element.update :srv_count  => step[1]["count"]
                  element.update :best => step[1]["best"].to_s
                  object.push element     
                end
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
              token = Digest::MD5.hexdigest(o[:funnel_name] + "+" + (o[:token] || ''))
              funnel = Funnel.find_by_token_and_at_date(token,o[:funnel_property_id])
              next if funnel.nil?
              funnel_property = FunnelProperty.find_by_date_and_name_and_funnel_id(o[:funnel_property_id],o[:funnel_property_name],funnel[:id].to_s)
              next if funnel_property.nil?
              
              funnel_property_value = FunnelPropertyValue.find_by_funnel_property_id_and_name(funnel_property[:id].to_s,o[:value_name])
              next if funnel_property_value.nil?
              
              o.update :funnel_property_value_id => funnel_property_value[:id].to_s
              o.delete :funnel_name
              o.delete :funnel_id 
              o.delete :token
              o.delete :funnel_property_id
              o.delete :funnel_property_name
              o.delete :value_name
              object = self.find_or_initialize_by_funnel_property_value_id_and_name(o[:funnel_property_value_id],o[:name])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

