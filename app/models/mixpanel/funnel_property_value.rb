require 'digest/md5'

module BusinessDomain
  module Mixpanel
    class FunnelPropertyValue < Base

      has_many :funnel_property_steps
      belongs_to :funnel_property

      def self.table_name
        "mixpanel_funnel_property_values"
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
                  element = {}
                  element[:funnel_property_id] = key
                  element.update :name => value[0]
                  element.update :end  => value[1]["end"]
                  element.update :start => value[1]["start"]
                  element.update :total_visitors => value[1]["total_visitors"]
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
              token = Digest::MD5.hexdigest(o[:funnel_name] + "+" + (o[:token] || ''))
              funnel = Funnel.find_by_token_and_at_date(token,o[:funnel_property_id])
              next if funnel.nil?
              funnel_property = FunnelProperty.find_by_date_and_name_and_funnel_id(o[:funnel_property_id],o[:funnel_property_name],funnel[:id].to_s)
              next if funnel_property.nil?
              o.update :funnel_id => funnel[:id].to_s
              o.update :funnel_property_id => funnel_property[:id].to_s
              o.delete :funnel_name
              o.delete :funnel_property_name
              o.delete :funnel_id 
              o.delete :token
              object = self.find_or_initialize_by_funnel_property_id_and_name(o[:funnel_property_id],o[:name])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

