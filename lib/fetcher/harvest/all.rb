module Fetcher
  module Harvest
    class All
      include Fetcher::Harvest::Client
      include Fetcher::Harvest::Project

      def initialize(credential)
        super(credential)
        raise ArgumentError, "This site required a subdomain, please specify the subdomain along with credential!" if single_fetch? && credential[:subdomain].nil?
      end

      def fetch_all
        if single_fetch?
          fetch_client(credential)
        else
          logger.info "multi fetch"
          credential.each do |cd|
            fetch_client(cd)
          end
        end
      end
    end
  end
end
