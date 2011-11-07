module BusinessDomain
  class Parser

#######################################################################################################
#      params has  :parent ===> root node
#                  :mapper ===> element is mapped to node
#                  :change ===> in case update from source table, can reference task or iteration model
#                                            or ticket model
#                  :be_array ===> get sub array ref: iteration_story model
#                  :root ===> use to get root of JSON
#                  :key ===> field contain keys in hash converted from JSON
#                  :value ===> field contain values in hash converted from JSON
#                  :field_pos ===> in case the field to ref. is not "content"
#######################################################################################################

    def self.parse(content, params, type = "XML")
      obj = parse_XML(content, params) if type == "XML"
      obj = params[:block].call(content) if type == "SPEC"
      return obj
    end

    def self.parse_all(target, type = "XML")
      arr_obj = get_content(target.src_data,target.filter_params, type)
      target.update_data(arr_obj) unless arr_obj.nil?
    end

#      for RSpec
    def self.get_content(src_data,params, type = "XML")
      arr_obj = []
      field_pos = params[:field_pos] || :content
      src_data.find(:all).each do |o|
        obj = parse_XML(o[field_pos], params) if type == "XML"
        obj = params[:block].call(o[field_pos]) if type == "SPEC"
        unless params[:change].nil? 
          temp = params[:change]
#          turn to array if not array
          temp = [params[:change]] unless params[:change][0].kind_of?(Array)  
          obj.each {|element| temp.each {|sub_array| element.update sub_array[0] => o[sub_array[1]]}}
        end
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
      doc.xpath(params[:parent],params[:namespace]).each do |n|
        element = {}
        params[:mapper].each do |p|
         element.update p[0] => n.xpath(p[1]).text
          unless params[:be_array].nil?            
            temp = params[:be_array]
#              turn to array if not array
            temp = [params[:be_array]] unless params[:be_array][0].kind_of?(Array)             
            temp.each do |sub_array|
              if sub_array[0] == p[0]
#                create sub array for nested realationship
                arr_ele = []
                n.xpath(p[1]).each { |ele| arr_ele.push ele.xpath(sub_array[1]).text }
                element.update p[0] => arr_ele
              end
            end
          end # end unless
          element.delete p[0] if n.xpath(p[1]).text == ''
        end # end params[:mapper].each
        contain.push(element) unless element[params[:key_field]].blank? and params[:key_field]
      end
      contain
    end
  end
end

