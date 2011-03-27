module Fetcher
  module GA
    class All
      include Fetcher::GA::Account
      include Fetcher::GA::Data

      def initialize(credential, params)
        #<subdomain>:<username>:<password>
        if !credential.is_a?(Hash)
          username, password = credential.split(":")
          credential = {:username => username, :password => password}
          params = {:startdate => startdate, :endate => enddate, :metrics => metrics}
          super(credential, params)
        else 
          super(credential, params)
        end
      end

      def fetch_all
        if single_fetch?
          fetch(credential, params)
        else
          logger.info "multi fetch"
          credential.each do |cd|
          puts credential
          puts params
            fetch(cd, params)
          end
        end
      end

      def fetch(credential, params)
        login
        fetch_account(credential)
        fetch_data(credential, params)
#        fetch_webproperty(credential)
 #       fetch_profile(credential)
  #      fetch_goal(credential)
   #     fetch_segment(credential)
        logout
      end
      
    end
  end
end

