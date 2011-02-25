require "rexml/document"
include REXML

module Fetcher
  module Harvest
    module ExpenseCategory
      include Fetcher::Harvest::Base

      def fetch_expense_categories(credential)
        response_parse_logic = Proc.new do |response|
          content_keys = {}
          doc = Document.new(response)
          doc.elements.each("expense-categories/expense-category") do |ec| 
            content_keys["#{ec.elements["name"].text}"] = ec.to_s
          end
          content_keys
        end
        fetch("ExpenseCategory", ::Harvest::ExpenseCategory, credential, HARVEST_CONFIG["apis"]["expense_categories"], response_parse_logic)
      end
    end
  end
end
