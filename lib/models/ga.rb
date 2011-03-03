require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module GA
  class Account < ActiveRecord::Base
    def self.table_name
      "ga_accounts"
    end
  end
end
