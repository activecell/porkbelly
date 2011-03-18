module Fetcher
  module GA
    module Account
      include Fetcher::GA::Base

      attr_accessor :account_id
      
      def fetch_account(credential)
        request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"]
        response = create_request(request_url)
        logger.info "Created login request url: #{request_url}"
        @account_id = extract_account_id(response)
        content = response
        begin
          save_account(account_id, content, credential, request_url)
        rescue Exception => e
          #TODO: send email here  
          puts e
        end
        logger.info "Updated data"
      end

      def save_account(account_id, content, credential, request_url)
        ga_account =  ::GA::Account.find_or_initialize_by_account_id(account_id)
        logger.info ga_account.inspect
        ga_account.update_attributes({:account_id => account_id,
                                      :content => content, 
                                      :credential => extract_credential(credential), 
                                      :request_url => request_url,
                                      :format => "xml"})
      end

      def extract_account_id(response)
        entry = Nokogiri::XML(response).search("entry")
        account_id = entry.at_xpath("dxp:property").values[1]
        account_id
      end

    end
  end
end

