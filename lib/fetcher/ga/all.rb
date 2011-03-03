module Fetcher
  module GA
    class All
      include Fetcher::GA::Account

      def initialize(credential)
        super(credential)
        #raise ArgumentError, "This site required a subdomain, please specify the subdomain along with credential!" if single_fetch? && credential[:subdomain].nil?
      end

      def fetch_all
        if single_fetch?
          fetch_account(credential)
        else
          logger.info "multi fetch"
          credential.each do |cd|
            fetch_account(credential)
          end
        end
      end
    end
  end
end
