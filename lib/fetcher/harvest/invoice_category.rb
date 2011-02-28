require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module InvoiceCategory
      include Fetcher::Harvest::Base

      def fetch_invoice_categories(credential)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("invoice-item-categories/invoice-item-category") do |ec| 
            content_keys["#{ec.elements["id"].text}"] = ec.to_s
          end
          content_keys
        end
        fetch(::Harvest::InvoiceCategory, credential, HARVEST_CONFIG["apis"]["invoice_categories"], response_parse_logic)
      end
    end
  end
end
