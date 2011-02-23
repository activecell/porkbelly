module Fetcher
  # this module contains a list of common methods that will be used in all fetchers
  module Base

    APIS_CONFIG = ::YAML::load(File.open(File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "apis.yml"))))[::STAGE]

    attr_accessor :credential
    def initialize(credential)
      raise ArgumentError, "Invalid credential, credential can be only Hash(single fetch) or Array(multiple fetch)" if (credential.nil? or credential.empty?) or (!credential.kind_of?(Array) and !credential.kind_of?(Hash)) 
      @credential = credential
    end

    def single_fetch?
      credential.kind_of?(Hash)
    end

    # get the logger
    def logger
      raise NotImplementedError.new("Implement this method to return the logger for a specific site.")
    end

    # send notification exception
    def notify_exception(site, exception)
      Mailers::ExceptionNotificationMailer.exception_notification(site, exception).deliver  
    end

    # extract unique identifiers from the response(xml/json)
    # params:
    #   response: xml/json response
    def extract_content_keys(response)
      raise NotImplementedError.new("Implement this method to return a hash of unique key and content.")
    end

    # get a list of existence keys from db based on the given credential
    # params:
    #   credential: 
    def existence_keys(credential)
      raise NotImplementedError.new("Implement this method to return a list of credential and key.")
    end

    # base class for all loggers
    class BaseLogger < Logger
      def format_message(severity, timestamp, progname, msg)
        "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
      end
    end
  end
end
