module Fetcher
  module GA
    class All
      include Fetcher::GA::Account
      include Fetcher::GA::WebProperty
      include Fetcher::GA::Profile
      include Fetcher::GA::Goal
      include Fetcher::GA::Segment

      def initialize(credential)
        super(credential)
        #raise ArgumentError, "This site required a subdomain, please specify the subdomain along with credential!" if single_fetch? && credential[:subdomain].nil?
      end

      def fetch_all
        if single_fetch?
          login
          fetch_account(credential)
          fetch_webproperty(credential)
          fetch_profile(credential)
          fetch_goal(credential)
          fetch_segment(credential)
          logout
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

