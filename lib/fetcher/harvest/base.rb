require "logger"
require "yaml"
require "rest-client"

module Fetcher
  module Harvest
    # include this module in all Harvest fetchers
    module Base
      include Fetcher::Base

      HARVEST_CONFIG = APIS_CONFIG['harvest']
      SITE = "HARVEST"

      @@logger = BaseLogger.new(File.join(File.dirname(__FILE__), "..", "..", "..", "log", "harvest.log"))
      def logger
        @@logger
      end

      def create_request(credential, request_url, params = {})
        options = {
          :user => credential[:username], 
          :password => credential[:password],
          :content_type => :xml, 
          :accept => :xml
        }
        # convert params hash to request param string
        request_url = request_url + "?" + hash_to_param_string(params) unless params.empty?
        logger.info "Create request #{request_url}"
        RestClient::Resource.new(request_url, options)
      end

      def fetch(target, model_class, credential, target_api, response_parse_logic)
        logger.info "Fetching #{target} ..."
        target_ids = []
        tracking = ::SiteTracking.find_or_initialize_by_site_and_target(SITE, target)
        begin
          base_url = HARVEST_CONFIG["base_url"].gsub(/\[SUBDOMAIN\]/, credential[:subdomain]) + target_api
          params = {}
          params[:updated_since] = tracking.last_request.strftime("%Y-%m-%d %H:%M") if tracking and tracking.last_request
          response = create_request(credential, base_url, params).get.to_s
          logger.info "Response #{response}"
          content_keys = response_parse_logic.call(response)
          if content_keys.kind_of?(Hash) and !content_keys.empty?
            content_keys.each do |key, content|
              target_ids << key
              target_entity = model_class.find_or_initialize_by_target_id(key)
              # insert of update target
              target_entity.update_attributes({
                :request_url => base_url, 
                :content => content, 
                :credential => Hash[*credential.sort.flatten].to_s, 
                :format => HARVEST_CONFIG["format"]
              })
            end
          end
        rescue Exception => exception
          logger.error exception
          logger.error exception.backtrace
          notify_exception(SITE, exception)
        ensure
          # update tracking record for the next fetch
          tracking.update_attributes({:last_request => Time.now})
        end
        logger.info "Fetched #{target}."
        return target_ids
      end
    end
  end
end
