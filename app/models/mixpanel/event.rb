require 'digest/md5'

module BusinessDomain
  module Mixpanel
    class Event < Base

      def self.table_name
        "mixpanel_events"
      end

      # override method

      def self.src_data
        return ::Mixpanel::Event
      end

      def self.filter_params
        params = {}
        params.update :root => "data/values"
        params.update :key => :at_date
        params.update :value => :srv_count
        params.update :change => [[:name,:target_id],[:token,:credential]]
        params.update :block => lambda {|content|
            object = []
            data = JSON content
            roots = params[:root].split('/')
            roots.each {|element| data = data[element]}
            
            data.each do |key, value| 
              data[key].each do |a|
                next if a[1] == 0
                element = {}
                element.update params[:key] => a[0]
                element.update params[:value] => a[1]
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

