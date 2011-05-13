require 'nokogiri'

module Fetcher
  module Harvest
    module Timesheet
      include Fetcher::Harvest::Base

      def fetch_timesheets(credential,tracking)
        response_parse_logic = lambda {|response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          content_keys["#{doc.xpath("/daily/for_day").text}"] = response
          return content_keys
        }
        # TODO: add time tracking here
        year = 2010
        day_of_year = 100
        if tracking.last_request
          year = Time.parse(tracking.last_request.strftime("%Y-%m-%d %H:%M")).utc.year
          day_of_year = Time.parse(tracking.last_request.strftime("%Y-%m-%d %H:%M")).utc.yday
        end
        (year..Time.now.utc.year).each do |y|
          max_day = 366
          max_day = Time.now.utc.yday if y == Time.now.utc.year 
          (day_of_year..max_day).each do |d|
            api_url = HARVEST_CONFIG["apis"]["timesheets"].gsub("[DAY_OF_YEAR]", d.to_s).gsub("[YEAR]", y.to_s)
            fetch(::Harvest::Timesheet, credential, api_url, response_parse_logic, false)
          end
#          reset day of year
          day_of_year = 1
        end
      end
    end
  end
end
