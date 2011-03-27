module Fetcher
  module GA
    module Data
      include Fetcher::GA::Base

      attr_accessor :account_id
      def fetch_data(credential)
        puts "fetching data"
      end

    end
  end
end

