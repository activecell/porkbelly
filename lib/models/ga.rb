require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module GA
  class Account < ActiveRecord::Base
    def self.table_name
      "ga_src_accounts"
    end
  end
  class WebProperty < ActiveRecord::Base
    def self.table_name
      "ga_src_web_properties"
    end
  end
  class Profile < ActiveRecord::Base
    def self.table_name
      "ga_src_profiles"
    end
  end
  class Goal < ActiveRecord::Base
    def self.table_name
      "ga_src_goals"
    end
  end
  class Segment < ActiveRecord::Base
    def self.table_name
      "ga_src_segments"
    end
  end
  class Data < ActiveRecord::Base
    def self.table_name
      "ga_data"
    end
  end


end

