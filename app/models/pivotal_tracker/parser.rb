module BusinessDomain
  module PivotalTracker
    class Parser

      def self.parse(content, params)
        parse_XML(params[:parent],content,params[:mapper])
      end

      def self.parse_all(target)
        arr_obj = get_content(target.src_data,target.filter_params)
        target.update_data(arr_obj) unless arr_obj.nil?
      end

#      for RSpec
      def self.get_content(src_data,params)
        arr_obj = []
        src_data.find(:all).each do |o|
          obj = parse(o.content, params)
          arr_obj.push(obj) unless obj.blank?
        end
        arr_obj.blank? ? nil : arr_obj
      end

      private
#      parse a text with format xml to database
#      finds children from parent_node
      def self.parse_XML(parent,content,params)

        contain = []
        doc = Nokogiri::XML(content)
        doc.xpath(parent).each do |n|
          element = {}
          params.each do |p|
            element[p[0]] = n.xpath(p[1]).text
          end
          contain.push(element) unless element.blank?
        end
        contain
      end
    end
  end
end

