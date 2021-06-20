# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
# Learn more: http://github.com/javan/whenever

set :output, "/path/to/my/cron_log.log"

every 1.day do
  rake "company:update_to_latest"
end
