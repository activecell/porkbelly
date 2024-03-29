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
      include Fetcher::Harvest::InvoiceMessage
      include Fetcher::Harvest::InvoicePayment
      include Fetcher::Harvest::UserAssignment
      include Fetcher::Harvest::TaskAssignment
      include Fetcher::Harvest::Timesheet

      def initialize(credential)
        if !credential.is_a?(Hash)
          subdomain, username, password = credential.split(":")
          credential = {:subdomain => subdomain, :username => username, :password => password}
          super(credential)
        else super(credential)
        raise ArgumentError, "This site required a subdomain, please specify the subdomain along with credential!" if single_fetch? && credential[:subdomain].nil?
        end
      end

      def fetch_all
        begin
          tracking = ::SiteTracking.find_or_initialize_by_site_and_target(SITE, SITE)
          fetch_time = Time.now.utc
          has_error = false
          
          if single_fetch?
            fetch_clients(credential)
            fetch_contacts(credential)

            project_ids = fetch_projects(credential)
            fetch_user_assignments(credential, project_ids)
            fetch_task_assignments(credential, project_ids)

            fetch_tasks(credential)
            fetch_people(credential)
            fetch_expense_categories(credential)
            fetch_expenses(credential)

            invoice_ids = fetch_invoices(credential)
            fetch_invoice_messages(credential, invoice_ids)
            fetch_invoice_payments(credential, invoice_ids)

            fetch_invoice_categories(credential)
            fetch_timesheets(credential,tracking)
            logger.info "FETCH COMPLETED."
          else
            logger.info "multi fetch"
            credential.each do |cd|
              fetch_client(cd)
              fetch_contact(cd)

              project_ids = fetch_projects(cd)
              fetch_user_assignments(cd, project_ids)
              fetch_task_assignments(cd, project_ids)

              fetch_tasks(cd)
              fetch_people(cd)
              fetch_expense_categories(cd)
              fetch_expenses(cd)

              invoice_ids = fetch_invoices(cd)
              fetch_invoice_messages(cd, invoice_ids)
              fetch_invoice_payments(cd, invoice_ids)

              fetch_invoice_categories(cd)
              fetch_timesheets(cd,tracking)
            end
            logger.info "FETCH COMPLETED."
          end
          if !has_error
            tracking.update_attributes({:last_request => fetch_time})
          end
        rescue Exception => exc
          logger.error exc
          logger.error exc.backtrace
          notify_exception(SITE, exc)
        end
      end
    end
  end
end
