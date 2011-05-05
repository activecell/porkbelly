$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require File.expand_path(File.join(File.dirname(__FILE__), '..', "config", "boot"))
require File.expand_path(File.join(File.dirname(__FILE__), "mailers", "exception_notification_mailer"))

# models
require 'models/site_tracking'
require 'models/harvest'
require 'models/mixpanel'
require 'models/zendesk'
require 'models/pivotal_tracker'
require 'models/ga'
require 'models/salesforce'

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
require 'fetcher/zendesk/view'
require 'fetcher/zendesk/ticket'
require 'fetcher/zendesk/post'
require 'fetcher/zendesk/all'

# PIVOTAL TRACKER
require 'fetcher/pivotal_tracker/base'
require 'fetcher/pivotal_tracker/project'
require 'fetcher/pivotal_tracker/activity'
require 'fetcher/pivotal_tracker/membership'
require 'fetcher/pivotal_tracker/iteration'
require 'fetcher/pivotal_tracker/story'
require 'fetcher/pivotal_tracker/task'
require 'fetcher/pivotal_tracker/note'
require 'fetcher/pivotal_tracker/all'

#GOOGLE ANALYTIC
require 'fetcher/ga/base'
require 'fetcher/ga/account'
require 'fetcher/ga/data'
#require 'fetcher/ga/webproperty'
#require 'fetcher/ga/profile'
#require 'fetcher/ga/goal'
#require 'fetcher/ga/segment'
require 'fetcher/ga/all'

# SALESFORCE
require 'fetcher/salesforce/base'
require 'fetcher/salesforce/object_metadata'
require 'fetcher/salesforce/object_data'
require 'fetcher/salesforce/all'

module Fetcher
  VERSION = "1.0.0"
end

# ---- BUSINESS DOMAIN --- #
#Utility
require 'app/models/utility/parser'

# PIVOTAL TRACKER
require 'app/models/pivotal_tracker/base'
require 'app/models/pivotal_tracker/project'
require 'app/models/pivotal_tracker/activity'
require 'app/models/pivotal_tracker/story'
require 'app/models/pivotal_tracker/iteration'
require 'app/models/pivotal_tracker/note'
require 'app/models/pivotal_tracker/task'
require 'app/models/pivotal_tracker/person'
require 'app/models/pivotal_tracker/membership'
require 'app/models/pivotal_tracker/iteration_story'
require 'app/models/pivotal_tracker/history_track'
require 'app/models/pivotal_tracker/story_note'
require 'app/models/pivotal_tracker/all'

# ZENDESK
require 'app/models/zendesk/base'
require 'app/models/zendesk/organization'
require 'app/models/zendesk/ticket'
require 'app/models/zendesk/view'
require 'app/models/zendesk/comment'
require 'app/models/zendesk/all'

