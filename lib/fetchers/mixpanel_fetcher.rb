require File.expand_path("../base", __FILE__)
require File.expand_path("../../models/mixpanel", __FILE__)
require "mixpanel_client"

module Fetchers
  class MixpanelFetcher
    include Base

    # create logger for mixpanel
    @@logger = BaseLogger.new(File.expand_path("../../../log/mixpanel.log",__FILE__))
    def logger
      @@logger
    end

    # fetch data for the given credential
    def fetch_data(credential)
      begin
        client = Mixpanel::Client.new('api_key' => credential[:api_key], 'api_secret' => credential[:api_secret])
        data = client.request do
          resource 'events/retention'
          event    '["test-event"]'
          type     'general'
          unit     'hour'
          interval  24
          bucket   'test'
        end
        # insert data into database
        event = MP::Event.create!(:content => data, :credential => credential[:api_key])
      rescue Exception => exception
        notify_exception("MIXPANEL", exception)
      end
    end
  end
end

Fetchers::MixpanelFetcher.new.fetch_data({:api_key => "4d9b20366fda6e248d8d282946fc988a", :api_secret => "b58997c62b91b19fe039b017ccb6b668"})
