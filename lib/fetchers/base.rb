require File.expand_path("../../mailers/exception_notification_mailer", __FILE__)
require "logger"

module Fetchers
  module Base

    # abstract method to retrieve the user credentials (username/password or api_key) for the given site,
    # subsclass have to implement its own version
    def get_api_credentials(credentials_source)
      raise NotImplementedError.new("This method should be overriden and return credentials of a site.")
    end

    # Params:
    #   data_type: type of data need fetching.
    #   credential: authentication info (username/password or api_key).
    #   params: optional parameters.
    def fetch_data(data_type, credential, params={})
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
  end

  # base class for all loggers
  class BaseLogger < Logger
    def format_message(severity, timestamp, progname, msg)
      "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
    end
  end
end
