module BusinessDomain
  module Harvest
    class Base < ActiveRecord::Base
      DATE_TIME_FORMAT = "%Y/%m/%d"
#      will be overrided by sub class
      def self.filter_params
        params = {}
        return params
      end

#      will be overrided by sub class
      def self.src_data
        self #should be replaced by related table
      end

#      will be overrided by sub class
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = self.find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

