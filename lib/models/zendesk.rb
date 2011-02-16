require File.expand_path("../../../initializers/database", __FILE__)

module Zendesk
  class Ticket < ActiveRecord::Base
    def self.table_name
      "zendesk_tickets"
    end
  end
end
