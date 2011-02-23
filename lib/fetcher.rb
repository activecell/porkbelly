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
require 'fetcher/harvest/project'
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
require 'fetcher/zendesk/all'

module Fetcher
  VERSION = "1.0.0"
end
