module Fetcher
  module GA
    module Profile
      include Fetcher::GA::Base

      def load_webproperty_ids
        ga_wp = ::GA::WebProperty
        @wps = ga_wp.find(:all)
      end

      def fetch_profile(credential)
        load_webproperty_ids
        @wps.each do |wp|
          wp_id = wp.web_property_id
          account_id = wp.account_id
          request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"] + 
"/" + account_id.to_s + GA_CONFIG["apis"]["webproperties"] + "/" + wp_id.to_s + GA_CONFIG["apis"]["profiles"]
          response = create_request(@@auth_key, request_url)
          contents = extract_profiles(response)
          save_profile(response, contents, credential, request_url)
        end
      end

      def save_profile(response, contents, credential, request_url)
        entries = contents[0]
        a_ids = contents[1]
        wp_ids = contents[2]
        profile_names = contents[3]
        profile_ids = contents[4]
        dxp_table_ids = contents[5]
        i = 0
        for i in (i..entries.size - 1) do
          entry = entries[i]
          a_id = a_ids[i]
          wp_id = wp_ids[i]
          profile_name = profile_names[i]
          profile_id = profile_ids[i]
          dxp_table_id = dxp_table_ids[i]
          ga_profile =  ::GA::Profile.find_or_initialize_by_profile_id(profile_id)
          ga_profile.update_attributes({:account_id => a_id, 
                                        :web_property_id => wp_id, 
                                        :entry => entry.to_s, 
                                        :profile_name => profile_name.to_s, 
                                        :profile_id => profile_id,
                                        :dxp_table_id => dxp_table_id, 
                                        :content => response.to_s, 
                                        :credential => credential, 
                                        :request_url => request_url, 
                                        :format => "xml"})
        end
      end

      def extract_profiles(response)
        entries = Nokogiri::XML(response).search("entry")
        a_ids = Array.new
        wp_ids = Array.new
        profile_names = Array.new
        profile_ids = Array.new
        dxp_table_ids = Array.new
        contents = Array.new
        i = 0
        for i in (i..entries.xpath("//dxp:property").size - 1) do
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:accountId"
            a_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_i
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:webPropertyId"
            wp_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_s
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:profileName"
            profile_names << entries.xpath("//dxp:property")[i].attribute('value').value.to_s
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:profileId"
            profile_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_i
          end
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "dxp:tableId"
            dxp_table_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_s
          end
        end
        contents = [entries, a_ids, wp_ids, profile_names, profile_ids, dxp_table_ids]
      end

    end
  end
end
