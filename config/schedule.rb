# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"~
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :output, "/home/tin/works/profitably/log/cron.log"
# Learn more: http://github.com/javan/whenever
sites = ["ga", "harvest", "mixpanel", "pt", "zendesk"]
every 1.minute do
  sites.each do |site|
    rake "site:#{site}:all credentials=#{File.expand_path(File.join(File.dirname(__FILE__), '..', "doc", "#{site}.csv"))}"
  end
end


