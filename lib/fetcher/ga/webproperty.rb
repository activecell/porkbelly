module Fetcher
  module GA
    module WebProperty
      include Fetcher::GA::Base

      def fetch_webproperty(credential)
        account = ::GA::Account.find_by_credential(credential.inspect)
        request_url = GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"] + 
"/" + account.account_id.to_s + GA_CONFIG["apis"]["webproperties"]
        response = create_request(request_url)
        contents = extract_web_property_contents(response)
        save_webproperty(response, contents, credential, request_url)
      end

      def save_webproperty(response, contents, credential, request_url)
        entries = contents[0]
        a_ids = contents[1]
        wp_ids = contents[2]
        i = 0
        for i in (i..entries.size - 1) do
          entry = entries[i]
          a_id = a_ids[i]
          wp_id = wp_ids[i]
          ga_web_property =  ::GA::WebProperty.find_or_initialize_by_web_property_id(wp_id)
          ga_web_property.update_attributes({:account_id => a_id,
                                             :web_property_id => wp_id,
                                             :entry => entry.to_s,
                                             :content => response.to_s,
                                             :credential => credential.inspect,
                                             :request_url => request_url, :format => "xml"})
        end
      end

      def extract_web_property_contents(response)
        entry = Nokogiri::XML(response).search("entry")
        entries = Array.new
        a_ids = Array.new
        wp_ids = Array.new
        contents = Array.new
        i = 0
        for i in (i..entry.xpath("//dxp:property").size - 1) do
          if (i%2 == 0)
            a_id = entry.xpath("//dxp:property")[i].attribute('value').value.to_i
            a_ids << a_id
          else
            wp_id = entry.xpath("//dxp:property")[i].attribute('value').value.to_s
            wp_ids << wp_id
          end
        end
        entry.each do |e|
          entries << e
        end
        contents = [entries, a_ids, wp_ids]
        contents
      end

    end
  end
end
