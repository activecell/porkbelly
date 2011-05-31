module BusinessDomain
  module GA
    class Profile < Base

      has_many :entries

      def self.table_name
        "ga_profiles"
      end

      # override method
      
      def self.src_data
        return ::GA::Account
      end

      def self.filter_params
        params = {}
        params.update :change => [:account_id, :account_id]
        params.update :field_pos => :entry
        params.update :block => lambda {|content|
          contain = []
          doc = Nokogiri::XML(content)
          doc.remove_namespaces!
          element = {}
          element.update :title => doc.xpath('//title').text
          doc.xpath("//*").each do |ele|
            name = ele.xpath("@name").text
            if !name[3..-1].nil?
              cut_name = name[3..-1]
              sym = cut_name.to_sym 
              element.update(sym => ele.xpath("@value").text) if Profile.column_names.include? cut_name
            end
          end
          contain.push(element)
          return contain
        }
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = self.find_or_initialize_by_profileId_and_account_id(o[:profileId],o[:account_id].to_s)
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

