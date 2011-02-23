require "rubygems"
require File.expand_path(File.join(File.dirname(__FILE__), "config", "boot"))
require File.expand_path(File.join(File.dirname(__FILE__), "lib", "fetcher"))
require "active_record"
require "yaml"
require "sqlite3"

PROJECT_DIR = File.dirname(__FILE__)
DATABASE_CONFIG = YAML::load(File.open(File.join(PROJECT_DIR, "config", "database.yml")))
DB_FILE = File.join(PROJECT_DIR, DATABASE_CONFIG[STAGE]["database"])

namespace :site do
  task :harvest => :"harvest:all" # default fetch all data
  namespace :harvest do
    desc "Fetch all harvest data"
    task :all do
      usage = %q{
        ***************************
        Description:
          Get all data of the Harvest site
        Usage: 
          rake site:harvest credentials=<path_to_credentials_csv_file> #=> get all data of the given credentials
          rake site:harvest credential=<username>:<password> #=> get all data of the given credential
          Replace variable in <> with actual params
        **************************
      }
      # validate arguments
      unless ENV.include?("credentials") or ENV.include?("credential")
        #raise usage
      end
      client = Fetcher::Harvest::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      client.fetch_all
    end
  end

  task :pivotal => :"pivotal:all" # default fetch all data
  namespace :pivotal do
    desc "Fetch all Pivotal Tracker data for the given credentials (single/multiple)"

    task :all do
      puts "Fetching all data..."
    end
  end

  task :mixpanel => :"mixpanel:all" # default fetch all data
  namespace :mixpanel do
    desc "Fetch all Mixpanel events for the given credentials (single/multiple)"

    def fetch_mixpanel_data(data_type)
      usage = %q{    
        ***************************
        Description:
          Get all data of the Mixpanel site
        Usage: 
          rake site:mixpanel credentials=<path_to_credentials_csv_file> #=> get all data with many credentials
          rake site:harvest credential="<api_key>:<api_secret>" #=> get all data with the given credential
          Replace variable in <> with actual params
        **************************
      }

      # Setup params.
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end
      
      credential_source = ENV["credentials"] || ENV["credential"]
      
      method = ENV["method"]

      @params = {}

      if ENV.include?("params")
        @params = Helpers::Util.hash_from_query_string!(ENV["params"])
        if @params == nil || @params.empty?
          raise usage
        end
      end

      puts "Data type= #{data_type}. Fetching data from Mixpanel with credentials: '#{credential_source}'..."

      # Begin fetching data.
      fetcher = Fetcher::Mixpanel::All.new(credential_source)

      puts "=== #{Time.now}: Fetching events and funnels data..."
      
      fetcher.fetch_data('fetch_all', @params)
      
      puts "=== #{Time.now}: Finished fetching events and funnels data."
    end

    task :all do
      fetch_mixpanel_data(:all)
    end
  end

  task :zendesk => :"zendesk:all" # default fetch all data
  namespace :zendesk do
    desc "Fetch all zendesk data"
    task :all do
      usage = %q{
        ***************************
        Description:
          Get all data of the Zendesk site
        Usage: 
          rake site:zendesk credentials=<path_to_credentials_csv_file> #=> get all data of the given credentials
          rake site:zendesk credential=<username>:<password> #=> get all data of the given credential
          Replace variable in <> with actual params
        **************************
      }
      # validate arguments
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end
      client = Fetcher::Zendesk::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
      client.fetch_all
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
