require "rubygems"
require "bundler/setup"
require "active_record"
require "yaml"
require "sqlite3"
require File.expand_path("../initializers/stage", __FILE__)
require File.expand_path("../lib/helpers/util", __FILE__)

PROJECT_DIR = File.dirname(__FILE__)
DB_CONFIG = YAML::load(File.open(File.join(PROJECT_DIR, "config", "database.yml")))
DB_FILE = File.join(PROJECT_DIR, DB_CONFIG[STAGE]["database"])

namespace :site do
  namespace :pivotal do
    desc "Fetch all Pivotal Tracker data for the given credentials (single/multiple)"
    
    task :all do
      puts "Fetching all data..."
    end
  end
  
  namespace :mixpanel do
    desc "Fetch all Mixpanel events for the given credentials (single/multiple)"
    
    def fetch_mixpanel_data(data_type)
      usage = %q{Usage: rake site:mixpanel:events credentials=<your credentials> [params="a=query&b=string"] [method=""]
Options:
  credentials: with two options:
        "api_key=f0aa346688cee071cd85d857285a3464, api_secret=adna346688cee071cd85d857285a3464"
    Or: "/etc/mixpanel_credentials.csv"
    The CSV must be formatted as the following:
      api_key, api_secret
      key1, secret1
      key2, secret2
  params: see http://mixpanel.com/api/docs/guides/api for API reference.
  method: one of the following methods: all_events, names, top, retention. Default is 'all_events'
      }
      
      # Setup params.
      unless ENV.include?("credentials")
        raise usage
      end
      
      method = ENV["method"]
      
      @params = {}
      
      if ENV.include?("params")
        @params = Util.hash_from_query_string!(ENV["params"])
        if @params == nil || @params.empty?
          raise usage
        end
      end
      
      require File.expand_path("../lib/fetchers/mixpanel_fetcher", __FILE__)
      puts "Data type= #{data_type}. Fetching data from Mixpanel with credentials: '#{ENV['credentials']}'..."
      
      # Begin fetching data.
      fetcher = Fetchers::MpFetchers::MixpanelFetcher.new     
      
      credentials = fetcher.get_api_credentials(ENV["credentials"])
      
      if credentials.is_a?(Array) # from CSV file.
        credentials.each do |credent|
          puts "=== #{Time.now}: Fetching data ..."
          fetcher.fetch_data(credent, data_type, @params, method)
          puts "=== #{Time.now}: Finished ==="
        end        
      else # params from command line.
        puts "=== #{Time.now}: Fetching data ..."
        fetcher.fetch_data(credentials, data_type, @params, method)
        puts "=== #{Time.now}: Finished ==="
      end 
    end
       
    task :all do
      fetch_mixpanel_data(:all)
    end
    
    task :events do
      fetch_mixpanel_data(:events)
    end
    
    task :event_properties do
      fetch_mixpanel_data(:event_properties)
    end
    
    task :funnels do
      fetch_mixpanel_data(:funnels)
    end
    
    task :funnel_properties do
      fetch_mixpanel_data(:funnel_properties)
    end
  end 
  
	############################################################
	##-----ZENDESK RAKE TASK----##
	############################################################

  #---------------  TICKET FETCH  ---------------#
	namespace :zendesk do
		desc "Fetch Zendesk tickets using given agentemail and password"
		task :tickets do
			require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
			credential = {
				:agentemail => "utwkidvn@gmail.com",
				:password => "tpl123456",
			}
			request_url = "http://tpltest.zendesk.com/users.xml"
			format = "xml"
			fetcher = Fetchers::TicketFetcher.new(credential, request_url, format)						
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
