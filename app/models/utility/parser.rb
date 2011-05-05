module BusinessDomain
  class Parser

#######################################################################################################
#      params has  :parent ===> root node
#                  :mapper ===> element is mapped to node
#                  :change ===> in case update from source table, can reference task or iteration model
#                                            or ticket model
#                  :be_array ===> get sub array ref: iteration_story model
#######################################################################################################

    def self.parse(content, params)
      parse_XML(content,params)
    end

    def self.parse_all(target)
      arr_obj = get_content(target.src_data,target.filter_params)
      target.update_data(arr_obj) unless arr_obj.nil?
    end

#      for RSpec
    def self.get_content(src_data,params)
      arr_obj = []
      src_data.find(:all).each do |o|
        obj = parse_XML(o.content, params)
        obj.each { |element| element.update params[:change][0] => o[params[:change][1]]} unless params[:change].nil?
        arr_obj.push(obj) unless obj.blank?
      end
      arr_obj.blank? ? nil : arr_obj
    end

    private
#      parse a text with format xml to database
#      finds children from parent_node
    def self.parse_XML(content,params)
      contain = []
      doc = Nokogiri::XML(content)
      doc.xpath(params[:parent]).each do |n|
        element = {}
        params[:mapper].each do |p|
          unless params[:be_array].nil?
            if params[:be_array][0] == p[0]
#                create sub array for nested realationship
              arr_ele = []
              n.xpath(p[1]).each { |ele| arr_ele.push ele.xpath(params[:be_array][1]).text }
              element[p[0]] = arr_ele
            else
              element.update p[0] => n.xpath(p[1]).text
            end
          else
            element.update p[0] => n.xpath(p[1]).text
          end

        end
        contain.push(element) unless element[params[:key_field]].blank?
      end
      contain
    end
  end
end

