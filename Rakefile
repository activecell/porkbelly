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
    
    task :all do
      
    end
    
    task :events do
      unless ENV.include?("credentials")
        raise "usage: rake site:mixpanel:events credentials=<your credentials> [params]"
      end
      
      params = {}
      
      require File.expand_path("../lib/fetchers/mixpanel_fetcher", __FILE__)
      puts "Fetching all events for '#{ENV['credentials']}'..."
      
      #~ credentials = {
        #~ :api_key => "4d9b20366fda6e248d8d282946fc988a",
        #~ :api_secret => "b58997c62b91b19fe039b017ccb6b668",
      #~ }
      
      fetcher = Fetchers::MpFetchers::MixpanelFetcher.new     
      
      credentials = fetcher.get_api_credentials(ENV['credentials'])
      
      if credentials.is_a?(Array) # From CSV file.
        credentials.each do |c|
          puts "=== Fetching data ... ==="
          data = fetcher.fetch_data(:events, c, params)      
          puts "=== Result: #{data}"
        end        
      else # params from command line.
        data = fetcher.fetch_data(:events, credentials, params)      
        puts "Result: #{data}"
      end
      
    end
  end

	############################################################
	##-----ZENDESK RAKE TASK----##
	############################################################
	namespace :zendesk do
		desc "Fetch Zendesk tickets using given agentemail and password"
		task :tickets do
			require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
			credentials = {
				:agentemail => "utwkidvn@gmail.com",
				:password => "tpl123456",
			}
			fetcher = Fetchers::TicketFetcher.new
			fetcher.fetch_data
			puts "Fetching all tickets"
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
