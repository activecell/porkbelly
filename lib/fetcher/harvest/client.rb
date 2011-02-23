require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module Client
      include Fetcher::Harvest::Base

      def fetch_client(credential)
        target = "Client"
        request_url =  HARVEST_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + HARVEST_CONFIG["apis"]["clients"]
        response = create_request(@credential, request_url).get.to_s
        content_keys = extract_keys(response)
        tracking = ::SiteTracking.where(:site => SITE, :target => target).first
        if tracking
          # check for new data
          logger.info "last update #{tracking.last_request}"
        else
          first_time_tracking(content_keys)
        end
      end

      private
        # insert new records into database and create a new tracking record
        def first_time_tracking(content_keys)
          unless content_keys.nil? and content_keys.empty?
            # insert new records
            content_keys.each do  |target_id, content|
              ::Harvest::Client.create!(
                :request_url => request_url, 
                :content => content, 
                :credential => @credential.to_s, 
                :format => HARVEST_CONFIG["format"],
                :target_id => target_id
              )
            end
            # create new tracking record (each target has only one tracking record)
            ::SiteTracking.create!(:site => SITE, :target => target, :last_request => Time.now)
          end
        end

        def send_request
          request_url =  HARVEST_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + HARVEST_CONFIG["apis"]["clients"]
          response = create_request(@credential, request_url).get.to_s
          response
        end

        def extract_keys(response)
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("clients/client") do |client| 
            content_keys["#{client.elements["id"].text}"] = client.to_s
          end
          content_keys
        end
    end
  end
end
