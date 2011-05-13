require 'nokogiri'

module Fetcher
  module Harvest
    module ExpenseCategory
      include Fetcher::Harvest::Base

      def fetch_expense_categories(credential)
        response_parse_logic = lambda do |response|
          content_keys = {}
          doc = Nokogiri::XML(response)
          doc.xpath("/expense-categories/expense-category").each do |node|
            content_keys["#{node.xpath("name").first.text}"] = node.to_s
          end
          content_keys
        end
        fetch(::Harvest::ExpenseCategory, credential, HARVEST_CONFIG["apis"]["expense_categories"], response_parse_logic)
      end
    end
  end
end
