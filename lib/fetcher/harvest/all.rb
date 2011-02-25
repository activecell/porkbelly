module Fetcher
  module Harvest
    class All
      include Fetcher::Harvest::Client
      include Fetcher::Harvest::Project
      include Fetcher::Harvest::Contact
      include Fetcher::Harvest::Task
      include Fetcher::Harvest::User
      include Fetcher::Harvest::ExpenseCategory
      include Fetcher::Harvest::Expense
      include Fetcher::Harvest::Invoice
      include Fetcher::Harvest::InvoiceCategory

      def initialize(credential)
        super(credential)
        raise ArgumentError, "This site required a subdomain, please specify the subdomain along with credential!" if single_fetch? && credential[:subdomain].nil?
      end

      def fetch_all
        if single_fetch?
          fetch_clients(credential)
          fetch_contacts(credential)
          fetch_projects(credential)
          fetch_tasks(credential)
          fetch_people(credential)
          fetch_expense_categories(credential)
          fetch_expenses(credential)
          fetch_invoices(credential)
          fetch_invoice_categories(credential)
        else
          logger.info "multi fetch"
          credential.each do |cd|
            fetch_client(cd)
            fetch_contact(cd)
            fetch_projects(cd)
            fetch_tasks(cd)
            fetch_people(cd)
            fetch_expense_categories(cd)
            fetch_expenses(cd)
            fetch_invoices(cd)
            fetch_invoice_categories(cd)
          end
        end
      end
    end
  end
end
