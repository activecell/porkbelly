module Fetcher
  module Zendesk
    class All
      include Fetcher::Zendesk::Organization

      def initialize(credential)
        super(credential)
        raise ArgumentError, "This site required a subdomain, please specify the subdomain along with credential!" if single_fetch? && credential[:subdomain].nil?
        puts credential
      end

      def fetch
      end

      def fetch_all
        if single_fetch?
          fetch_client(credential)
        else
          logger.info "multi fetch"
          credential.each do |cd|
            fetch_client(credential)
          end
        end
      end
    end
  end
end
