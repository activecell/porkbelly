module Fetcher
  module GA
    module Profile
      include Fetcher::GA::Base

      attr_accessor :content_keys
      def fetch_profile(credential)
        Garb::Session.login(credential[:username], credential[:password])
        accounts = Garb::Management::Account.all
        accounts.each do |account|
          account.profiles.each do |profile|
            puts profile.id
          end
        end
      end
    end
  end
end

