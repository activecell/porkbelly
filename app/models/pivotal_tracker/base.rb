require 'rubygems'
require 'nokogiri'

module BusinessDomain
  module PivotalTracker
    class Base < ActiveRecord::Base
      @@params = []
      @@parent = ''
      @@src_data = ''
      def self.parse(obj)
        parse_content(obj.content)
      end

      def self.parse_all
        transaction do
          arr_obj = []
          @@src_data.find(:all).each do |o|
            arr_obj.push parse(o)
          end
          arr_obj.each do |o|
            object = find_or_initialize_by_target_id(o[:target_id])
            object.update_attributes(o)
          end
        end
      end

      protected

      # parse a text with format xml to database
      # finds children from parent_node
      def self.parse_content(content)
        contain = {}
        doc = Nokogiri::XML(content)
        doc.xpath(@@parent).each do |n|
          @@params.each do |p|
            contain[p[0]] = n.xpath(p[1]).text
          end
        end
        contain
      end
    end
  end
end

