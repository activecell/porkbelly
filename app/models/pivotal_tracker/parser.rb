module BusinessDomain
  module PivotalTracker
    class Parser

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
          contain.push(element)
        end
        contain
      end
    end
  end
end

