module Fetcher
  module GA
    module Goal
      include Fetcher::GA::Base

      def load_profile_ids
        ga_profile = ::GA::Profile
        @profiles = ga_profile.find(:all)
      end

      def fetch_goal(credential)
        load_profile_ids
        @profiles.each do |profile|
          profile_id = profile.profile_id
          account_id = profile.account_id
          wp_id = profile.web_property_id
          request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"] + 
"/" + account_id.to_s + GA_CONFIG["apis"]["webproperties"] + "/" + wp_id.to_s + 
"/" + GA_CONFIG["apis"]["profiles"] + "/" + profile_id.to_s + GA_CONFIG["apis"]["goals"]
          response = create_request(@@auth_key, request_url)
          contents = extract_goal(response)
          save_profile(response, contents, credential, request_url)
        end
      end

      def save_profile(response, contents, credential, request_url)
        entries = contents[0]
        profile_ids = contents[1]
        goal_names = contents[2]
        ga_goal =  ::GA::Goal
        i = 0
        for i in (i..entries.size - 1) do
          entry = entries[i]
          profile_id = profile_ids[i]
          name = goal_names[i]
          ga_goal.create(:entry => entry.to_s, 
                         :profile_id => profile_id,
                         :name => name,
                         :content => response.to_s, 
                         :credential => credential, 
                         :request_url => request_url, 
                         :format => "xml")
        end
      end

    end
  end
end
