module BusinessDomain
  module GA
    class Entry < Base

      belongs_to :profile

      def self.table_name
        "ga_entries"
      end

      # override method
      
      def self.src_data
        return ::GA::Data
      end

      def self.filter_params
        params = {}
        params.update :change => [[:account_id, :account_id],[:profile_id,:table_id]]
        params.update :mapper => [[:visitorType,'ga:visitorType'],
                                  [:pagePath,'ga:pagePath'],
                                  [:date,'ga:date'],
                                  [:referralPath,'ga:referralPath'],
                                  [:campaign,'ga:campaign'],
                                  [:source,'ga:source'],
                                  [:hostname,'ga:hostname'],
                                  [:pagePath,'ga:pagePath'],
                                  [:visitors,'ga:visitors'],
                                  [:visits,'ga:visits'],
                                  [:pageviews,'ga:pageviews'],
                                  [:pageviewsPerVisit,'ga:pageviewsPerVisit'],
                                  [:uniquePageviews,'ga:uniquePageviews'],
                                  [:avgTimeOnPage,'ga:avgTimeOnPage'],
                                  [:avgTimeOnSite,'ga:avgTimeOnSite'],
                                  [:entrances,'ga:entrances'],
                                  [:exits,'ga:exits'],
                                  [:organicSearches,'ga:organicSearches'],
                                  [:impressions,'ga:impressions'],
                                  [:adClicks,'ga:adClicks'],
                                  [:adCost,'ga:adCost'],
                                  [:CPM,'ga:CPM'],
                                  [:CPC,'ga:CPC'],
                                  [:CTR,'ga:CTR'],
                                  [:costPerGoalConversion,'ga:costPerGoalConversion'],
                                  [:costPerTransaction,'ga:costPerTransaction'],
                                  [:costPerConversion,'ga:costPerConversion'],
                                  [:RPC,'ga:RPC']]
        params.update :block => lambda {|content|
          contain = []
          doc = Nokogiri::XML(content)
          doc.remove_namespaces!
          doc.xpath("//entry").each do |node|
            element = {}
            node.xpath("*").each do |ele|
              name = ele.xpath("@name").text
              sym = name[3..-1].to_sym if !name[3..-1].nil?
              element.update(sym => ele.xpath("@value").text) if params[:mapper].include? [sym,name]
            end
            contain.push(element)
          end
          return contain
        }
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              profile = nil
              profile = Profile.find_by_account_id_and_profileId(o[:account_id].to_s,o[:profile_id][3..-1])
              next if profile.nil?
              object = self.find_or_initialize_by_date_and_account_id_and_profile_id(o[:date],o[:account_id],profile[:id])
              o.update :profile_id => profile[:id]
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

