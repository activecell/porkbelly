module Fetcher
  module GA
    class All
      include Fetcher::GA::Account
      include Fetcher::GA::WebProperty
      include Fetcher::GA::Profile
      include Fetcher::GA::Goal
      include Fetcher::GA::Segment

      def initialize(credential)
        #<subdomain>:<username>:<password>
        if !credential.is_a?(Hash)
          username, password = credential.split(":")
          credential = {:username => username, :password => password}
          super(credential)
        else 
          super(credential)
        end
      end

      def fetch_all
        if single_fetch?
          fetch(credential)
        else
          logger.info "multi fetch"
          credential.each do |cd|
            fetch(cd)
          end
        end
      end

      def fetch(credential)
        login
        fetch_account(credential)
        fetch_webproperty(credential)
        fetch_profile(credential)
        fetch_goal(credential)
        fetch_segment(credential)
        logout
      end
      
    end
  end
end

