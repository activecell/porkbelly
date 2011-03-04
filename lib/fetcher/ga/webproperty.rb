module Fetcher
  module GA
    module WebProperty
      include Fetcher::GA::Base

      def load_account_ids
        ga_account = ::GA::Account
        @accounts = ga_account.find(:all)
      end

      def fetch_webproperty(credential)
        load_account_ids
        @accounts.each do |a|
          a_id = a.account_id
          request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"] + 
"/" + a_id.to_s + GA_CONFIG["apis"]["webproperties"]
          response = create_request(@@auth_key, request_url)
          contents = extract_web_property_contents(response)
          save_webproperty(response, contents, credential, request_url)
        end
      end

      def save_webproperty(response, contents, credential, request_url)
        entries = contents[0]
        a_ids = contents[1]
        wp_ids = contents[2]
        ga_web_property =  ::GA::WebProperty
        i = 0
        for i in (i..contents.size - 1) do
          entry = entries[i]
          a_id = a_ids[i]
          wp_id = wp_ids[i]
          ga_web_property.create(:account_id => a_id, :web_property_id => wp_id, 
:entry => entry.to_s, :content => response.to_s, :credential => credential, 
:request_url => request_url, :format => "xml")
        end
      end

    end
  end
end
