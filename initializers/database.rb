require File.expand_path("../../initializers/boot", __FILE__)
require "active_record"
require "yaml"
require File.expand_path("../../initializers/stage", __FILE__)

#Time.zone = "UTC"
DB_CONFIG = YAML::load(File.open(File.expand_path("../../config/database.yml", __FILE__)))
ActiveRecord::Base.establish_connection(DB_CONFIG[STAGE])
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.time_zone_aware_attributes = true
