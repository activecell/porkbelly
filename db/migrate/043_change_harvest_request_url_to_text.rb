class ChangeHarvestRequestUrlToText < ActiveRecord::Migration
  def self.up    
    [ :harvest_clients, 
      :harvest_contacts, 
      :harvest_expense_categories,
      :harvest_expenses, 
      :harvest_invoice_categories,
      :harvest_invoice_messages,
      :harvest_invoice_payments, 
      :harvest_invoices, 
      :harvest_people,
      :harvest_projects,
      :harvest_task_assignments,
      :harvest_tasks,
      :harvest_timesheets,
      :harvest_user_assignments].each do |table_name|
        change_table table_name do |t|
          t.change :request_url, :text
        end
    end
  end
end
