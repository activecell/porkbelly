require File.expand_path("../base", __FILE__)
require File.expand_path("../../models/zendesk", __FILE__)
require "active_support/core_ext"
require 'json'
require 'rest-client'

module Fetchers
	module ZendeskFetcherBase
		FORMAT = {:json => 'json', :xml => 'xml', :csv => 'csv'}
		DEFAULT_LIMIT = 255
		SITE = "http://tpltest.zendesk.com/users.xml"
		AGENTEMAIL = "utwkidvn@gmail.com"
		PASSWORD = "tpl123456"
		
		def self.request_url
	  	RestClient::Resource.new(SITE, :user => AGENTEMAIL, :password => PASSWORD)
		end				
	end

	class TicketFetcher
		include ZendeskFetcherBase
		def fetch_data
			data = ZendeskFetcherBase.request_url.get
			Zendesk::Ticket.create(:params => "a", :content => data, :credential => "sax")
		end
	end
end




