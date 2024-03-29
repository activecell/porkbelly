require "cgi"
require 'digest/sha1'

module Fetcher
  # this module contains a list of common methods that will be used in all fetchers
  module Base

    APIS_CONFIG = ::YAML::load(File.open(File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "apis.yml"))))[::STAGE]

    attr_accessor :credential
    attr_accessor :params
    def initialize(*args)
      raise ArgumentError, "Invalid credential, credential can be only Hash(single fetch) or Array(multiple fetch)" if (args[0].nil? or args[0].empty?) or (!args[0].kind_of?(Array) and !args[0].kind_of?(Hash))
      @credential = args[0]
      @params = args[1]
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

    # Generate SHA1 hash string from a plain text.
    def to_sha1(plain_text)
      ::Digest::SHA1.hexdigest(plain_text.to_s)
    end

    def hash_to_param_string(param_hash)
      arr_param = []
      param_hash.each do |key, value|
        arr_param << (CGI::escape(key.to_s) + "=" + CGI::escape(value))
      end
      arr_param.join("&")
    end

    # base class for all loggers
    class BaseLogger < Logger
      def format_message(severity, timestamp, progname, msg)
        "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
      end
    end
  end
end

