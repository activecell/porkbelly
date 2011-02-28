require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module InvoicePayment
      include Fetcher::Harvest::Base

      def fetch_invoice_payments(credential, invoice_ids)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("payments/payment") do |ec| 
            content_keys["#{ec.elements["id"].text}"] = ec.to_s
          end
          content_keys
        end

        invoice_ids.each do |inv_id|
          fetch(::Harvest::InvoicePayment, credential, HARVEST_CONFIG["apis"]["invoice_payments"].gsub("[INVOICE_ID]", inv_id), response_parse_logic, false, {:invoice_id => inv_id})
        end
      end
    end
  end
end
