module BusinessDomain
  module Harvest
    class All
      include ::BusinessDomain
      def self.parse_all
        Parser.parse_all Client
        Parser.parse_all Contact
        Parser.parse_all Project
        Parser.parse_all Task
        Parser.parse_all User
        Parser.parse_all ExpenseCategory
        Parser.parse_all Expense
        Parser.parse_all UserAssignment
        Parser.parse_all TaskAssignment
        Parser.parse_all DayEntry
        Parser.parse_all Invoice
        Parser.parse_all InvoiceMessage 
        Parser.parse_all Payment
        Parser.parse_all InvoiceCategory
      end
    end
  end
end

