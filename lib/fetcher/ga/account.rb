module Fetcher
  module GA
    module Account
      include Fetcher::GA::Base

      def fetch_account(credential)
        request_login_url =  GA_CONFIG["auth_url"].gsub(/\[EMAIL\]/, credential[:username]).gsub(/\[PASSWORD\]/, credential[:password])
        #puts request_url
        response_login = create_login_request(credential, request_login_url).get.to_s
        auth_key = response_login.split("Auth=").last
        request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"]
        response = create_request(auth_key, request_url)
        account_id = extract_account_id(response)
        content = response
        begin
          save_account(account_id, content, credential, request_url)
        rescue 
          raise "Data is not fully propered or adequate"
        end
      end

      def save_account(account_id, content, credential, request_url)
        ga_account =  ::GA::Account.find_or_initialize_by_account_id(account_id)
        logger.info ga_account.inspect
        ga_account.update_attributes({:account_id => account_id, :content => content, :credential => credential, :request_url => request_url})
      end

    end
  end
end

