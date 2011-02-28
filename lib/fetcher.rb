$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require File.expand_path(File.join(File.dirname(__FILE__), '..', "config", "boot"))
require File.expand_path(File.join(File.dirname(__FILE__), "mailers", "exception_notification_mailer"))

# models
require 'models/site_tracking'
require 'models/harvest'
require 'models/mixpanel'
require 'models/zendesk'

# base fetcher
require 'fetcher/base'

# ---- FETCHERS ---- #
# HARVEST
require 'fetcher/harvest/base'
require 'fetcher/harvest/client'
require 'fetcher/harvest/contact'
require 'fetcher/harvest/project'
require 'fetcher/harvest/task'
require 'fetcher/harvest/user'
require 'fetcher/harvest/expense_category'
require 'fetcher/harvest/expense'
require 'fetcher/harvest/invoice'
require 'fetcher/harvest/invoice_category'
require 'fetcher/harvest/invoice_message'
require 'fetcher/harvest/invoice_payment'
require 'fetcher/harvest/user_assignment'
require 'fetcher/harvest/task_assignment'
require 'fetcher/harvest/timesheet'
require 'fetcher/harvest/all'

# MIXPANEL
require 'helpers/util'
require 'fetcher/mixpanel/base'
require 'fetcher/mixpanel/event'
require 'fetcher/mixpanel/event_property'
require 'fetcher/mixpanel/funnel'
require 'fetcher/mixpanel/funnel_property'
require 'fetcher/mixpanel/all'

#ZENDEK
require 'fetcher/zendesk/base'
require 'fetcher/zendesk/organization'
require 'fetcher/zendesk/group'
require 'fetcher/zendesk/user'
require 'fetcher/zendesk/tag'
require 'fetcher/zendesk/forum'
require 'fetcher/zendesk/entry'
require 'fetcher/zendesk/ticket_field'
require 'fetcher/zendesk/macro'
require 'fetcher/zendesk/all'

module Fetcher
  VERSION = "1.0.0"
end
