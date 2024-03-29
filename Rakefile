require "rubygems"
require File.expand_path(File.join(File.dirname(__FILE__), "config", "boot"))
require File.expand_path(File.join(File.dirname(__FILE__), "lib", "fetcher"))
require "yaml"

# TODO: add task for parsing

PROJECT_DIR = File.dirname(__FILE__)
DATABASE_CONFIG = YAML::load(File.open(File.join(PROJECT_DIR, "config", "database.yml")))

namespace :site do
  task :harvest => :"harvest:all" # default fetch all data
  namespace :harvest do
    desc "Fetch all harvest data"
    task :all do
      usage = %q{
        ***************************
        Description:
          Get all data of the Zendesk site
        Usage:
          rake site:harvest credentials=<path_to_credentials_csv_file> #=> get all data of the given credentials
          rake site:harvest credential=<subdomain>:<username>:<password> #=> get all data of the given credential
          Replace variable in <> with actual params
        **************************
      }
      # validate arguments
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end
      credential_source = ENV["credentials"] || ENV["credential"]
      if ENV["credentials"]
        Helpers::Util.hash_from_csv(credential_source).each do |credential|
        client = Fetcher::Harvest::All.new({:subdomain => credential["subdomain"],
                                            :username => credential["username"],
                                            :password => credential["password"]})
        client.fetch_all
        end
      elsif ENV["credential"]
        client = Fetcher::Harvest::All.new(ENV["credential"])
        client.fetch_all
      end
    end
  end

  task :pt => :"pt:all" # default fetch all data
  namespace :pt do
    desc "Fetch all Pivotal Tracker data for the given credentials (single/multiple)"

    def fetch_pivotal_tracker_data
      usage = %q{
        ***************************
        Description:
          Get all data of the Pivotal Tracker site
        Usage:
          rake site:pt credentials=<path_to_credentials_csv_file> #=> get all data with many credentials
          rake site:pt credential="<username>:<password>"  #=> get all data with the given username and password
          rake site:pt credential="<token>"  #=> get all data with the given API token
          Replace variable in <> with actual params
        **************************
      }

      # Setup params.
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end

      credential_source = ENV["credentials"] || ENV["credential"]

      # Begin fetching data.
      fetcher = Fetcher::PivotalTracker::All.new(credential_source)

      puts "=== #{Time.now}: Fetching data from Pivotal Tracker with credential(s): '#{credential_source}'..."

      fetcher.fetch_all

      puts "=== #{Time.now}: Finished fetching data from Pivotal Tracker."
    end

    task :all do
      fetch_pivotal_tracker_data
    end
  end

  task :mixpanel => :"mixpanel:all" # default fetch all data
  namespace :mixpanel do
    desc "Fetch all Mixpanel events for the given credentials (single/multiple)"

    def fetch_mixpanel_data
      usage = %q{
        ***************************
        Description:
          Get all data of the Mixpanel site
        Usage:
          rake site:mixpanel credentials=<path_to_credentials_csv_file> #=> get all data with many credentials
          rake site:mixpanel credential="<api_key>:<api_secret>" #=> get all data with the given credential
          Replace variable in <> with actual params
        **************************
      }

      # Setup params.
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end

      credential_source = ENV["credentials"] || ENV["credential"]

      method = ENV["method"]

      puts "Fetching data from Mixpanel with credentials: '#{credential_source}'..."

      # Begin fetching data.
      fetcher = Fetcher::Mixpanel::All.new(credential_source)

      puts "=== #{Time.now}: Fetching events and funnels data..."

      fetcher.fetch_all

      puts "=== #{Time.now}: Finished fetching events and funnels data."
    end

    task :all do
      fetch_mixpanel_data
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
          rake site:zendesk credential=<subdomain>:<username>:<password> #=> get all data of the given credential
          Replace variable in <> with actual params
        **************************
      }
      # validate arguments
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end
      credential_source = ENV["credentials"] || ENV["credential"]
      if ENV["credentials"]
        Helpers::Util.hash_from_csv(credential_source).each do |credential|
        client = Fetcher::Zendesk::All.new({:subdomain => credential["subdomain"],
                                            :username => credential["username"],
                                            :password => credential["password"]})
        client.fetch_all
        end
      elsif ENV["credential"]
        client = Fetcher::Zendesk::All.new(ENV["credential"])
        client.fetch_all
      end
    end
  end

#  task :ga => :"ga:all"
#  namespace :ga do
#    desc "Fetch all google analytic feed"
#    task :all do
#      usage = %q{
#        ***************************
#        Description:
#          Get all data of the GoogleAnalytic site
#        Usage:
#          rake site:ga credentials=<path_to_credentials_csv_file> #=> get all data of the given credentials
#          rake site:ga credential=<username>:<password> #=> get all data of the given credential
#          Replace variable in <> with actual params
#        **************************
#      }
#      # validate arguments
#      unless ENV.include?("credentials") or ENV.include?("credential")
#        raise usage
#      end
#      credential_source = ENV["credentials"] || ENV["credential"]
#      if ENV["credentials"]
#        Helpers::Util.hash_from_csv(credential_source).each do |credential|
#          client = Fetcher::GA::All.new({:username => credential["username"],
#                                         :password => credential["password"]})
#          client.fetch_all
#        end
#      elsif ENV["credential"]
#        client = Fetcher::GA::All.new(ENV['credential'])
#        client.fetch_all
#      end
#    end
#  end

############################################################################
######## GA task with specified params
############################################################################
  task :ga => :"ga:account"
  namespace :ga do
    desc "Fetch all google analytic feed"
    task :account do
      usage = %q{
        ***************************
        Description:
          Get all data of the GoogleAnalytic site
        Usage:
          rake site:ga credentials=<path_to_credentials_csv_file> #=> get all data of the given credentials
          rake site:ga credential=<username>:<password> #=> get all data of the given credential
          Replace variable in <> with actual params
        **************************
      }
      # validate arguments
      unless ENV.include?("credentials") or ENV.include?("credential")
        raise usage
      end
      credential_source = ENV["credentials"] || ENV["credential"]
      params = ENV["ids"].to_s+" "+ENV["startdate"].to_s+" "+ENV["enddate"].to_s+" "+ENV["metrics"].to_s+" "+ENV["dimensions"].to_s
      if ENV["credentials"]
        Helpers::Util.hash_from_csv(credential_source).each do |credential|
        puts params
          client = Fetcher::GA::All.new({:username => credential["username"],
                                         :password => credential["password"]})
          client.fetch_acc
        end
      elsif ENV["credential"]
        puts params
       client = Fetcher::GA::All.new(ENV['credential'])
       client.fetch_acc
      end
    end
  end

  task :ga => :"ga:all"
  namespace :ga do
    desc "Fetch all google analytic feed"
    task :all do
      usage = %q{
        ***************************
        Description:
          Get all data of the GoogleAnalytic site
        Usage:
          rake site:ga credentials=<path_to_credentials_csv_file> startdate=<date> enddate=<date> metrics<metrics> #=> get all data of the given credentials
          rake site:ga credential=<username>:<password> startdate=<date> enddate=<date> metrics<metrics> #=> get all data of the given credential
          Replace variable in <> with actual params
        **************************
      }
      # validate arguments
      unless ENV.include?("credentials") or ENV.include?("credential") and ENV.include?("metrics")
        raise usage
      end
      credential_source = ENV["credentials"] || ENV["credential"]
      if ENV["credentials"]
        Helpers::Util.hash_from_csv(credential_source).each do |credential|
          client = Fetcher::GA::All.new({:username => credential["username"],
                                         :password => credential["password"]},
                                         {:metrics => ENV["metrics"].to_s,
                                         :dimensions => ENV["dimensions"].to_s,
                                         :request_id => ENV["request_name"].to_s})
          client.fetch_all
        end
      elsif ENV["credential"]
       client = Fetcher::GA::All.new(ENV['credential'],
                                     {:metrics => ENV["metrics"].to_s,
                                      :dimensions => EVN["dimensions"]})
       client.fetch_all
      end
    end
  end
end

namespace :db do
  desc "Create database"
  task :create do
    create_database DB_CONFIG[STAGE]
  end 
  
  def create_database (config)
    begin
      if config['adapter'] =~ /sqlite/
        if File.exist?(config['database'])
          puts "#{config['database']} already exists"
        else
          begin
            # Create the SQLite database
            ActiveRecord::Base.establish_connection(config)
            ActiveRecord::Base.connection
          rescue Exception => e
            puts e, *(e.backtrace)
            puts "Couldn't create database for #{DB_CONFIG.inspect}"
          end
        end
        return # Skip the else clause of begin/rescue
      else
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      end
    rescue
      case config['adapter']
      when /mysql/
        @charset   = ENV['CHARSET']   || 'utf8'
        @collation = ENV['COLLATION'] || 'utf8_unicode_ci'
        creation_options = {:charset => (config['charset'] || @charset), :collation => (config['collation'] || @collation)}
        error_class = config['adapter'] =~ /mysql2/ ? Mysql2::Error : Mysql::Error
        access_denied_error = 1045
        begin
          ActiveRecord::Base.establish_connection(config.merge('database' => nil))
          ActiveRecord::Base.connection.create_database(config['database'], creation_options)
          ActiveRecord::Base.establish_connection(config)
        rescue error_class => sqlerr
          if sqlerr.errno == access_denied_error
            puts "#{sqlerr.error}. \nPlease provide the root password for your mysql installation\n>"
            root_password = $stdin.gets.strip
            grant_statement = "GRANT ALL PRIVILEGES ON #{config['database']}.* " \
              "TO '#{config['username']}'@'localhost' " \
              "IDENTIFIED BY '#{config['password']}' WITH GRANT OPTION;"
            ActiveRecord::Base.establish_connection(config.merge(
                'database' => nil, 'username' => 'root', 'password' => root_password))
            ActiveRecord::Base.connection.create_database(config['database'], creation_options)
            ActiveRecord::Base.connection.execute grant_statement
            ActiveRecord::Base.establish_connection(config)
          else
            puts sqlerr.error
            puts "Couldn't create database for #{DB_CONFIG.inspect}, charset: #{config['charset'] || @charset}, collation: #{config['collation'] || @collation}"
            puts "(if you set the charset manually, make sure you have a matching collation)" if config['charset']
          end
        end
      when 'postgresql'
        
        @encoding = config['encoding'] || ENV['CHARSET'] || 'utf8'
        begin
          ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
          ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => @encoding))
          ActiveRecord::Base.establish_connection(config)
        rescue Exception => e
          puts e, *(e.backtrace)
          puts "Couldn't create database for #{DB_CONFIG.inspect}"
        end
      end
    else
      puts "#{config['database']} already exists"
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

    task :reset do
      ActiveRecord::Base.establish_connection(DB_CONFIG[STAGE])
      ActiveRecord::Migrator.down("db/migrate", ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
      ActiveRecord::Migrator.migrate("db/migrate", ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
    end
  end
end

namespace :parsing do
  # default parse all data
  task :pt => :"pt:all"
  task :zendesk => :"zendesk:all"
  task :harvest => :"harvest:all"
  task :mixpanel => :"mixpanel:all"
  task :ga => :"ga:all"
  
  namespace :pt do
    desc "Parser all data of Pivotal Tracker"
    task :all do
      # ENV['credentials'] = "doc/pt.csv"
      # TODO: remove comment for do fetching from here
      # Rake::Task["site:pt:all"].invoke
      parse_all_data_pt
    end

    def parse_all_data_pt
      BusinessDomain::PivotalTracker::All.parse_all
    end
  end

  namespace :zendesk do
    desc "Parser all data of Zendesk"
    task :all do
      parse_all_data_zendesk
    end
    def parse_all_data_zendesk
      BusinessDomain::Zendesk::All.parse_all
    end
  end
  
  namespace :harvest do
    desc "Parser all data of Harvest"
    task :all do
      parse_all_data_harvest
    end
    def parse_all_data_harvest
      BusinessDomain::Harvest::All.parse_all
    end
  end
  
  namespace :mixpanel do
    desc "Parser all data of Mixpanel"
    task :all do
      parse_all_data_mixpanel
    end
    def parse_all_data_mixpanel
      BusinessDomain::Mixpanel::All.parse_all
    end
  end  
  
  namespace :ga do
    desc "Parser all data of Google Analytics"
    task :all do
      parse_all_data_ga
    end
    def parse_all_data_ga
      BusinessDomain::GA::All.parse_all
    end
  end  
  
end

