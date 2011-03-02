module Fetcher
  module GA
    module Profile
      include Fetcher::GA::Base

      def fetch_profile(credential)
        request_login_url =  GA_CONFIG["auth_url"].gsub(/\[EMAIL\]/, credential[:username]).gsub(/\[PASSWORD\]/, credential[:password])
        #puts request_url
        response_login = create_login_request(credential, request_login_url).get.to_s
        auth_key = response_login.split("Auth=").last
        puts auth_key
        request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"]
        puts request_url
        response = create_request(auth_key, request_url).get
        puts response
      end

      def fetch_profile_(credential)
        Garb::Session.login(credential[:username], credential[:password])
        accounts = Garb::Management::Account.all
        accounts.each do |account|
          account.profiles.each do |profile|
            profile_id = profile.id.to_i
            title = profile.title.to_s
            account_id =  profile.account_id.to_i
            web_property_id = profile.web_property_id.to_s
            begin
              save_data(profile_id, title, account_id, web_property_id)
            rescue
              raise "Data is not fully propered or adequate."
            end
          end
        end
      end

      def save_data(profile_id, title, account_id, web_property_id)
        ga_profile =  ::GA::Profile.find_or_initialize_by_profile_id(profile_id)
        logger.info ga_profile.inspect
        ga_profile.update_attributes({:profile_id => profile_id, :title => title, :account_id => account_id, :web_property_id => web_property_id})
      end

    end
  end
end

