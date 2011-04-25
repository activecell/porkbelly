module Fetcher
  module GA
    module Account
      include Fetcher::GA::Base

      attr_accessor :account_id
      
      def fetch_account(credential)
        request_url =  GA_CONFIG["base_url"]
        response = create_request(request_url)
        logger.info "Created login request url: #{request_url}"
        @account_id = extract_account(response)[1][0]
        contents = extract_account(response)
        begin
          save_account(response, contents, credential, request_url)
        rescue Exception => e
          #TODO: send email here  
          puts e
        end
        logger.info "Updated data"
      end

      def save_account(response, contents, credential, request_url)
        entries = contents[0]
        a_ids = contents[1]
        table_ids = contents[2]
        i = 0
        for i in (i..entries.size - 1) do
          entry = entries[i]
          a_id = a_ids[i]
          table_id = table_ids[i]
          ga_profile =  ::GA::Account.find_or_initialize_by_table_id(table_id)
          ga_profile.update_attributes({:account_id => a_id, 
                                        :entry => entry.to_s, 
                                        :table_id => table_id, 
                                        :content => response.to_s, 
                                        :credential => extract_credential(credential), 
                                        :request_url => request_url, 
                                        :format => "xml"})
        end
      end

      def extract_account(response)
        entries = Nokogiri::XML(response).search("entry")
        a_ids = Array.new
        table_ids = Array.new
        contents = Array.new
        i = 0
        for i in (i..entries.xpath("//dxp:property").size - 1) do
          if entries.xpath("//dxp:property")[i].attribute('name').value.to_s.eql? "ga:accountId"
            a_ids << entries.xpath("//dxp:property")[i].attribute('value').value.to_i
          end
        end
        entries.each do |entry|
          table_ids << entry.at_xpath("dxp:tableId").text
        end
        contents = [entries, a_ids, table_ids]
      end

      def extract_account_id(response)
        entry = Nokogiri::XML(response).search("entry")
        account_id = entry.at_xpath("dxp:property").values[1]
        account_id
      end

    end
  end
end

