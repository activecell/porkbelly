require "rubygems"
require "bundler/setup"
require "active_record"
require "yaml"
require "sqlite3"
require File.expand_path("../initializers/stage", __FILE__)

PROJECT_DIR = File.dirname(__FILE__)
DB_CONFIG = YAML::load(File.open(File.join(PROJECT_DIR, "config", "database.yml")))
DB_FILE = File.join(PROJECT_DIR, DB_CONFIG[STAGE]["database"])

namespace :site do
  namespace :mixpanel do
    desc "Fetch all Mixpanel events for the given credentials (single/multiple)"
    task :events do
      unless ENV.include?("credentials")
        raise "usage: rake site:mixpanel:events credentials=<your credentials>"
      end
      #require File.expand_path("../lib/fetchers/mixpanel_fetcher", __FILE__)
      puts "Fetching all events for '#{ENV['credentials']}'..."
    end
  end
end

namespace :db do
  desc "Create database"
  task :create do
    puts STAGE
    unless File.exist?(DB_FILE)
      SQLite3::Database.new(DB_FILE)
    end
  end

  desc "Delete database"
  task :drop do
    if File.exist?(DB_FILE)
      File.delete(DB_FILE)
    end
  end

  task :migrate => :"migrate:up"
  namespace :migrate do
    desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
    task :up do
      ActiveRecord::Base.establish_connection(DB_CONFIG[STAGE])
      ActiveRecord::Migrator.migrate("db/migrate", ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
    end

    task :down do
      ActiveRecord::Base.establish_connection(DB_CONFIG[STAGE])
      ActiveRecord::Migrator.down("db/migrate", ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
    end
  end
end
