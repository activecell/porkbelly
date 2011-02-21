require File.expand_path("../../mailers/exception_notification_mailer", __FILE__)
require "logger"

module Fetchers
  module Base

    # abstract method to retrieve the user credentials (username/password or api_key) for the given site,
    # subsclass have to implement its own version
    def get_api_credentials(credentials_source)
      raise NotImplementedError.new("This method should be overriden and return credentials of a site.")
    end

    # Check and import data
    # Params:
    #   data_type: type of data need fetching.
    #   credential: authentication info (username/password or api_key).
    #   params: optional parameters.
    def fetch_data(data_type, credential, params={})
      # 1. Get xml/json response from api
      # 2. Extract single element from the response (key, content)
      # 3. Check existence
      #    a) If record existed, compare the content to determine update/ignore record
      #    b) If record does not exist, insert new record into database
      raise NotImplementedError.new("Implement this method to fetch data from the apis with the given credential.")
    end

    def logger
      raise NotImplementedError.new("Implement this method to return the logger for a specific site.")
    end

    def notify_exception(site, exception)
      logger.error "<======== [START EXCEPTION] ========>"
      logger.error exception
      logger.error "Backtrace:"
      exception.backtrace.each do |msg|
        logger.error msg
      end
      logger.info "Sending exception notification..."
      Mailers::ExceptionNotificationMailer.exception_notification(site, exception).deliver  
      logger.info "Sent notification."
      logger.error "<======== [END EXCEPTION] ========>"
    end

    # extract unique identifiers from the response(xml/json)
    # params:
    #   response: xml/json response
    def extract_keys(response)
      raise NotImplementedError.new("Implement this method to return the array of unique keys.")
    end

    # get a list of existence keys from db based on the given credential
    # params:
    #   credential: 
    def existence_keys(credential)
      raise NotImplementedError.new("Implement this method to return a list of credential and key.")
    end
  end

  # base class for all loggers
  class BaseLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
    end
  end
end
