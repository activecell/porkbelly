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
  method: 
    events: all_events, names, top, retention. Default is 'all_events'
    event_properties: all_properties, top, values. Default is 'all_properties'
    funnels: all_funnels, names, dates. Default is 'all_funnels'
    funnel_properties: all_properties, names. Default is 'all_properties'
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
  namespace :zendesk do
    desc "Fetch Zendesk tickets using given agentemail and password"
    #################  TICKET FETCH  #################
    task :tickets do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/tickets.xml"
      format = "xml"
      fetcher = Fetchers::TicketFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end

    #################  ORGANIZATION FETCH  #################
    desc "Fetch Zendesk organizations using given agentemail and password"
    task :organizations do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/organizations.xml"
      format = "xml"
      fetcher = Fetchers::OrganizationFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end		

    #################  GROUP FETCH  #################
    desc "Fetch Zendesk groups using given agentemail and password"
    task :groups do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/groups.xml"
      format = "xml"
      fetcher = Fetchers::GroupFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end

    #################  USER FETCH  #################
    desc "Fetch Zendesk users using given agentemail and password"
    task :users do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/users.xml"
      format = "xml"
      fetcher = Fetchers::UserFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end

    #################  TAG FETCH  #################
    desc "Fetch Zendesk tags using given agentemail and password"
    task :tags do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/tags.xml"
      format = "xml"
      fetcher = Fetchers::TagFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end

    #################  FORUM FETCH  #################
    desc "Fetch Zendesk forums using given agentemail and password"
    task :forums do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/forums.xml"
      format = "xml"
      fetcher = Fetchers::ForumFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end

    #################  TICKET FIELD FETCH  #################
    desc "Fetch Zendesk ticket fields using given agentemail and password"
    task :ticket_fields do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/ticket_fields.xml"
      format = "xml"
      fetcher = Fetchers::TicketFieldFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end

    #################  MACRO FETCH  #################
    desc "Fetch Zendesk macros using given agentemail and password"
    task :macros do
      require File.expand_path("../lib/fetchers/zendesk_fetcher", __FILE__)
      credential = {
        :agentemail => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.zendesk.com/macros.xml"
      format = "xml"
      fetcher = Fetchers::MacroFetcher.new(credential, request_url, format)
      fetcher.fetch_data
    end
  end

  task :harvest => :"harvest:all" # default fetch all data
  namespace :harvest do
    desc "Fetch all harvest data"
    task :all do
      # validate arguments
      usage = %q{
        ********************************************************************************************************
        Description:
          Get all data of the Harvest site
        Usage: 
          rake site:harvest credentials=<path_to_credentials_csv_file> #=> get all data of the given credentials
          rake site:harvest credential=<username>:<password> #=> get all data of the given credential
          Replace variable in <> with actual params
        ********************************************************************************************************
      }
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end

      require File.expand_path("../lib/fetchers/harvest_fetcher", __FILE__)

      credential = {
        :email => "utwkidvn@gmail.com",
        :password => "tpl123456",
      }
      request_url = "http://tpltest.harvestapp.com/clients"
      format = "xml"
      fetcher = Fetchers::HarvestFetcher::ClientFetcher.new(credential, request_url, format)	
      fetcher.fetch_data
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
