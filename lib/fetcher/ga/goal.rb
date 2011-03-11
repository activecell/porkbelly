module Fetcher
  module GA
    module Goal
      include Fetcher::GA::Base

      def load_profile_ids
        ga_profile = ::GA::Profile
        @profiles = ga_profile.where(:account_id => account_id)
      end

      def fetch_goal(credential)
        load_profile_ids
        @profiles.each do |profile|
          profile_id = profile.profile_id
          wp_id = profile.web_property_id
          request_url =  GA_CONFIG["base_url"] + GA_CONFIG["apis"]["accounts"] + 
"/" + account_id.to_s + GA_CONFIG["apis"]["webproperties"] + "/" + wp_id.to_s + 
GA_CONFIG["apis"]["profiles"] + "/" + profile_id.to_s + GA_CONFIG["apis"]["goals"]
          response = create_request(request_url)
          contents = extract_goal(response)
          save_goal(response, contents, credential, request_url)
        end
      end

      def save_goal(response, contents, credential, request_url)
        entries = contents[0]
        entry_ids = contents[1]
        profile_ids = contents[2]
        goal_names = contents[3]
        i = 0
        for i in (i..entries.size - 1) do
          entry = entries[i]
          entry_id = entry_ids[i]
          profile_id = profile_ids[i]
          name = goal_names[i]
          ga_goal =  ::GA::Goal.find_or_initialize_by_entry_id(entry_id)
          ga_goal.update_attributes({:entry => entry.to_s, 
                         :entry_id => entry_id,
                         :account_id => account_id,
                         :profile_id => profile_id,
                         :name => name,
                         :content => response.to_s, 
                         :credential => credential.inspect, 
                         :request_url => request_url, 
                         :format => "xml"})
        end
      end

      def extract_goal(response)
        entries = Nokogiri::XML(response).search("entry")
        entry_ids = Array.new
        profile_ids = Array.new
        goal_names = Array.new
        contents = Array.new
        entries.search("id").each do |goal|
          entry_ids << goal.text.to_s
        end
        entries.xpath("//ga:goal").each do |goal|
          goal_names << goal.attribute('name').value
        end
        entries.xpath("//dxp:property").each do |dxp_prop|
          profile_ids << dxp_prop.attribute('value').value
        end
        contents = [entries, entry_ids, profile_ids, goal_names]
      end

    end
  end
end
