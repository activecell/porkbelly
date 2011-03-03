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
          puts response
        end
      end

    end
  end
end
