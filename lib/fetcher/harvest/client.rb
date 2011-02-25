require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module Client
      include Fetcher::Harvest::Base

      def fetch_client(credential)
        begin
          tracking = ::SiteTracking.where(:site => SITE, :target => target).first
          if tracking
            # this is the subsequence fetch, so we get the updated data base on the last request time
            begin
              last_request_time = tracking.last_request.strftime("%Y-%m-%d %H:%M")
              response = create_request(credential, base_url, :updated_since => last_request_time).get.to_s
              content_keys = extract_keys(response)
              #unless content_keys.empty?
                #::Harvest::Client.where(:target_id => content_keys.keys)
                #a = ::Harvest::Client.new(:target_id => "00001111", :content => "test", :format => "xml", :credential => "", :request_url => "") {|c| c.id = 1}
                a = ::Harvest::Client.find_or_initialize_by_target_id("0000")
                logger.info a.inspect
                a.update_attributes({:content => "test", :format => "xml", :credential => "", :request_url => ""})
              #end
            rescue Exception => exception
              raise exception
            ensure
              # update tracking record for the next fetch
              tracking.last_request = Time.now
              tracking.save!
            end
          else
            # this is the first time fetch
            response = create_request(credential, base_url).get.to_s
            content_keys = extract_keys(response)
            first_time_tracking(content_keys)
          end
        rescue Exception => exception
          notify_exception(SITE, exception)
        end
      end

      private
      # insert new records into database and create a new tracking record
      def first_time_tracking(content_keys)
        unless content_keys.nil? and content_keys.empty?
          content_keys.each do |target_id, content|
            ::Harvest::Client.create!(
              :request_url => request_url, 
              :content => content, 
              :credential => credential.to_s, 
              :format => HARVEST_CONFIG["format"],
              :target_id => target_id
            )
          end
          # create new tracking record (each target has only one tracking record)
          ::SiteTracking.create!(:site => SITE, :target => target, :last_request => Time.now)
        end
      end

      def base_url
        request_url = HARVEST_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + HARVEST_CONFIG["apis"]["clients"]
      end

      def extract_keys(response)
        content_keys = {}
        doc = Document.new(response)
        doc.elements.each("clients/client") do |client| 
          content_keys["#{client.elements["id"].text}"] = client.to_s
        end
        content_keys
      end

      def target
        "Client"
      end
    end
  end
end
