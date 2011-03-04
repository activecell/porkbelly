require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module GA
  class Account < ActiveRecord::Base
    def self.table_name
      "ga_accounts"
    end
  end
  class WebProperty < ActiveRecord::Base
    def self.table_name
      "ga_web_properties"
    end
  end
  class Profile < ActiveRecord::Base
    def self.table_name
      "ga_profiles"
    end
  end

end
