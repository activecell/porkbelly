require File.expand_path("../../initializers/boot", __FILE__)
require "active_record"
require "yaml"
require File.expand_path("../../initializers/stage", __FILE__)

DB_CONFIG = YAML::load(File.open(File.expand_path("../../config/database.yml", __FILE__)))
ActiveRecord::Base.establish_connection(DB_CONFIG[STAGE])
