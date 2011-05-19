require 'digest/md5'

module BusinessDomain
  module Mixpanel
    class EventProperty < Base

      def self.table_name
        "mixpanel_event_properties"
      end

######################
#      override method
######################
      def self.src_data
        return ::Mixpanel::EventProperty
      end

      def self.filter_params
        params = {}
        params.update :root => "data/values"
        params.update :change => [[:name,:target_id],[:event_token,:event_name],[:credential,:credential]]
        params.update :block => lambda {|content|
            object = []
            data = JSON content
            roots = params[:root].split('/')
            roots.each {|element| data = data[element]}
            
            data.each do |key, value| 
              
              data[key].each do |a|
                next if a[1] == 0
                element = {}
                element.update :value => key
                element.update :at_date => a[0]
                element.update :srv_count => a[1]
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
              o[:event_token] = Digest::MD5.hexdigest(o[:event_token] + "+" + (o[:credential] || ''))
              o.delete :credential
              object = self.find_or_initialize_by_event_token_and_name_and_at_date_and_value(o[:event_token],o[:name],o[:at_date],o[:value])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

