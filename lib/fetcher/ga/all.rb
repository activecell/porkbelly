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
          params = {:metrics => metrics, :dimensions => dimensions}
          super(credential, params)
        else
          super(credential, params)
        end
      end

      def fetch_all
        tracking = ::SiteTracking.find_or_initialize_by_site_and_target(SITE, SITE)
        fetch_time = Time.now.utc
        has_error = false
        if single_fetch?
          puts params
          begin
            fetch(credential, params)
          rescue Exception => exc
            has_error = true
            puts exc
            puts exc.backtrace
          end
        else
          logger.info "multi fetch"
          credential.each do |cd|
            puts credential
            puts params
            begin
              fetch(cd, params)
            rescue Exception => exc
              has_error = true
              puts exc.backtrace
            end
          end
        end
        if !has_error
          tracking.update_attributes({:last_request => fetch_time})
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

