require 'digest/md5'

module BusinessDomain
  module Mixpanel
    class Funnel < Base

      def self.table_name
        "mixpanel_funnels"
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
              element = {}
              element.update :at_date => key
              element.update :completion => data[key]["analysis"]["completion"].to_s
              element.update :starting_amount => data[key]["analysis"]["starting_amount"].to_s
              element.update :worst => data[key]["analysis"]["worst"].to_s
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
              o[:token] = Digest::MD5.hexdigest(o[:name] + "+" + (o[:token] || ''))
              object = self.find_or_initialize_by_token_and_at_date(o[:token],o[:at_date])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

