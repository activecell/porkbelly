require 'digest/md5'

module BusinessDomain
  module Mixpanel
    class FunnelProperty < Base

      has_many :funnel_property_values
      belongs_to :funnel

      def self.table_name
        "mixpanel_funnel_properties"
      end

      ######################
      #      override method
      ######################
      def self.src_data
        return ::Mixpanel::FunnelProperty
      end

      def self.filter_params
        params = {}
        params.update :change => [[:name,:target_id],[:funnel_name,:funnel_name],[:token,:credential]]
        params.update :block => lambda {|content|
            object = []
            data = JSON content
            data.keys.each do |a|
              element = {}
              element.update :date => a 
              element.update :steps => data[a]["meta"]["steps"]
              element.update :values => data[a]["meta"]["values"].to_s
              object.push element
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
              funnel = Funnel.find_by_token_and_at_date(token,o[:date])
              next if funnel.nil?
              o.update :funnel_id => funnel[:id].to_s
              o.delete :funnel_name
              o.delete :token
              object = self.find_or_initialize_by_date_and_name_and_funnel_id(o[:date],o[:name],o[:funnel_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

