require File.expand_path("../base", __FILE__)
require File.expand_path("../../models/zendesk", __FILE__)
require "active_support/core_ext"
require 'json'
require 'rest-client'

module Fetchers
	module ZendeskFetcherBase
		FORMAT = {:json => 'json', :xml => 'xml', :csv => 'csv'}
		DEFAULT_LIMIT = 255
		
		def rest_request(credential, request_url)
	  	RestClient::Resource.new(request_url, :user => credential[:agentemail], :password => credential[:password])
		end
				
		def new_client(credential, request_url, format)
			@credential = credential.to_options
			@request_url = request_url
			@format = format
		end
		
		def check_existence_record(entity, data)
			if entity.where(:content => data).exists?
				return true
			else return false
			end
		end
	end

	class TicketFetcher
		include ZendeskFetcherBase
		@ticket_rest = nil
		def initialize(credential, request_url, format)
			new_client(credential, request_url, format)		
			create_rest_request(credential, request_url)
		end

		def create_rest_request(credential, request_url)
			@ticket_rest = rest_request(credential, request_url)
		end

		def fetch_data			
			data = @ticket_rest.get.to_s
			zendesk_ticket = Zendesk::Ticket
			if !check_existence_record(zendesk_ticket, data)			
				zendesk_ticket.create(:request_url => @request_url, :content => data, :credential =>	
@credential.to_s, :format => @format)
			end
		end
	end

	class OrganizationFetcher
		include ZendeskFetcherBase
		@organization_rest = nil
		def initialize(credential, request_url, format)
			new_client(credential, request_url, format)		
			create_rest_request(credential, request_url)
		end

		def create_rest_request(credential, request_url)
			@organization_rest = rest_request(credential, request_url)
		end

		def fetch_data			
			data = @organization_rest.get.to_s
			zendesk_organization =  Zendesk::Organization
			if !check_existence_record(zendesk_organization, data) 
				zendesk_organization.create(:request_url => @request_url, :content => data, :credential => @credential.to_s, :format => @format)
			end
		end
	end
end




