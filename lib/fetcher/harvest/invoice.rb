require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module Invoice
      include Fetcher::Harvest::Base

      def fetch_invoices(credential)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("invoices/invoice") do |invoice| 
            content_keys["#{invoice.elements["id"].text}"] = invoice.to_s
          end
          content_keys
        end
        fetch(::Harvest::Invoice, credential, HARVEST_CONFIG["apis"]["invoices"], response_parse_logic)
      end
    end
  end
end
