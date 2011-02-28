module Fetcher
  module Harvest
    module Timesheet
      include Fetcher::Harvest::Base

      def fetch_timesheets(credential)
        response_parse_logic = lambda {|response|
          content_keys = {}
          content_keys[Time.now.strftime("%Y-%m-%d")] = response
          return content_keys
        }
        api_url = HARVEST_CONFIG["apis"]["timesheets"].gsub("[DAY_OF_YEAR]", Time.now.yday.to_s).gsub("[YEAR]", Time.now.year.to_s)
        fetch(::Harvest::Timesheet, credential, api_url, response_parse_logic, false)
      end
    end
  end
end
