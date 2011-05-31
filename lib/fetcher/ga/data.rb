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
        tracking = ::SiteTracking.find_by_site_and_target(SITE, SITE)
        last_request = tracking.last_request.strftime("%Y-%m-%d") unless tracking.nil?
        @a_ids.each do |aid|
          table_id =  aid.table_id
          request_url =  GA_CONFIG["data_url"] + "ids=" + table_id.to_s
          if !last_request.blank?
            request_url << "&start-date=" << last_request
          else
            request_url << "&start-date=2010-01-01"
          end
          request_url << "&end-date=" << Time.now.utc.strftime("%Y-%m-%d") << "&metrics=" + params[:metrics].to_s
          request_url << "&dimensions="  + params[:dimensions].to_s unless params[:dimensions].blank? #dimensions can be nil
          request_for_pagination = request_url
          response = create_request(request_for_pagination)
          doc = Nokogiri::XML(response)
          total = doc.xpath("*/openSearch:totalResults").text.to_i
          index = doc.xpath("*/openSearch:startIndex").text.to_i
          items = doc.xpath("*/openSearch:itemsPerPage").text.to_i
          start_index = index + items
          # loop here
          while total > start_index
            save_data(response, account_id, table_id, credential, request_url)
            request_for_pagination = request_url + "&start-index=#{start_index}" + "&max-results=10000"
            response = create_request(request_for_pagination)
            doc = Nokogiri::XML(response)
            index = doc.xpath("*/openSearch:startIndex").text.to_i
            items = doc.xpath("*/openSearch:itemsPerPage").text.to_i
            start_index = index + items
          end
          logger.info "Created request url: #{request_for_pagination}"
          # puts response
          save_data(response, account_id, table_id, credential, request_url)
        end
      end

      def save_data(response, account_id, table_id, credential, request_url)
        ::GA::Data.transaction do
          ::GA::Data.create({:account_id => account_id,
                                     :table_id => table_id.to_s,
                                     :content => response.to_s,
                                     :credential => extract_credential(credential),
                                     :request_url => request_url})
        end
      end
    end
  end
end

