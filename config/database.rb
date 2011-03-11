require File.expand_path(File.join(File.dirname(__FILE__), "boot"))
require "active_record"
require "yaml"

DB_CONFIG = YAML::load(File.open(File.join(File.dirname(__FILE__), "database.yml")))
ActiveRecord::Base.establish_connection(DB_CONFIG[STAGE])
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.time_zone_aware_attributes = true
#ActiveRecord::Base.logger = Logger.new(File.expand_path(File.join(File.dirname(__FILE__), "..", "log", "activerecord.log")))
#ActiveRecord::Base.logger = Logger.new(STDOUT)
