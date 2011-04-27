module Fetcher
  module GA
    module Data
      include Fetcher::GA::Base

      def load_account_ids
        ga_aid = ::GA::Account
        @a_ids = ga_aid.where(:account_id => account_id)
      end

      def fetch_data(credential, params)
        load_account_ids
        @a_ids.each do |aid|
          table_id =  aid.table_id
          request_url =  GA_CONFIG["data_url"] + "ids=" + table_id.to_s + "&start-date=" + params[:startdate].to_s + "&end-date=" + params[:enddate].to_s + "&metrics=" + params[:metrics].to_s + "&dimensions=ga:day"
          response = create_request(request_url)
          logger.info "Created request url: #{request_url}"
          puts response
          save_data(response, account_id, table_id, credential, request_url)
        end
      end

      def save_data(response, account_id, table_id, credential, request_url)
        ga_data = ::GA::Data.find_or_initialize_by_table_id(table_id)
        ga_data.update_attributes({:account_id => account_id,
                                   :table_id => table_id.to_s,
                                   :content => response.to_s,
                                   :credential => extract_credential(credential),
                                   :request_url => request_url})
      end

    end
  end
end

