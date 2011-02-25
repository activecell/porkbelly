require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module Harvest
  class Client < ActiveRecord::Base
    def self.table_name
      "harvest_clients"
    end
  end

  class Contact < ActiveRecord::Base
    def self.table_name
      "harvest_contacts"
    end
  end

  class Project < ActiveRecord::Base
    def self.table_name
      "harvest_projects"
    end
  end

  class Task < ActiveRecord::Base
    def self.table_name
      "harvest_tasks"
    end
  end

  class User < ActiveRecord::Base
    def self.table_name
      "harvest_people"
    end
  end

  class ExpenseCategory < ActiveRecord::Base
    def self.table_name
      "harvest_expense_categories"
    end
  end
  
  class Expense < ActiveRecord::Base
    def self.table_name
      "harvest_expenses"
    end
  end

  class Invoice < ActiveRecord::Base
    def self.table_name
      "harvest_invoices"
    end
  end

  class InvoiceCategory < ActiveRecord::Base
    def self.table_name
      "harvest_invoice_categories"
    end
  end
end
