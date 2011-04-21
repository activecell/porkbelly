require 'rubygems'
require 'nokogiri'

module BusinessDomain
  module PivotalTracker
    class Base < ActiveRecord::Base
      @@params = []
      @@parent = ''
      @@src_data = ''
      def self.parse(content)
        parse_content(content)
      end

      def self.parse_all
        transaction do
          arr_obj = []
          @@src_data.find(:all).each do |o|
            arr_obj.push parse(o.content)
          end
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end

      protected

#     parse a text with format xml to database
#     finds children from parent node
      def self.parse_content(content)
        @@contain = Parser.parse_XML(@@parent,content,@@params)
        @@contain
      end
    end
  end
end

