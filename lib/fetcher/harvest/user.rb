module Fetcher
  module Harvest
    module User
      include Fetcher::Harvest::Base

      def fetch_people(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("users/user") do |user| 
            content_keys["#{user.elements["id"].text}"] = user.to_s
          end
          return content_keys
        }
        fetch(::Harvest::User, credential, HARVEST_CONFIG["apis"]["people"], response_parse_logic)
      end
    end
  end
end
