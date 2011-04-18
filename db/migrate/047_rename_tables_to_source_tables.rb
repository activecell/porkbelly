class RenameTablesToSourceTables < ActiveRecord::Migration
  def self.up
    rename_table :site_trackings, :site_src_trackings
    rename_table :mixpanel_events, :mixpanel_src_events
    rename_table :mixpanel_event_properties, :mixpanel_src_event_properties
    rename_table :mixpanel_funnels, :mixpanel_src_funnels
    rename_table :mixpanel_funnel_properties, :mixpanel_src_funnel_properties
    rename_table :harvest_clients, :harvest_src_clients
    rename_table :harvest_contacts, :harvest_src_contacts
    rename_table :harvest_expense_categories, :harvest_src_expense_categories
    rename_table :harvest_expenses, :harvest_src_expenses
    rename_table :harvest_invoice_categories, :harvest_src_invoice_categories
    rename_table :harvest_invoice_messages, :harvest_src_invoice_messages
    rename_table :harvest_invoice_payments, :harvest_src_invoice_payments
    rename_table :harvest_invoices, :harvest_src_invoices
    rename_table :harvest_people, :harvest_src_people
    rename_table :harvest_projects, :harvest_src_projects
    rename_table :harvest_task_assignments, :harvest_src_task_assignments
    rename_table :harvest_tasks, :harvest_src_tasks
    rename_table :harvest_timesheets, :harvest_src_timesheets
    rename_table :harvest_user_assignments, :harvest_src_user_assignments
    rename_table :ga_accounts, :ga_src_accounts
    rename_table :ga_goals, :ga_src_goals
    rename_table :ga_profiles, :ga_src_profiles
    rename_table :ga_segments, :ga_src_segments
    rename_table :ga_web_properties, :ga_src_web_properties
    rename_table :zendesk_entries, :zendesk_src_entries
    rename_table :zendesk_forums, :zendesk_src_forums
    rename_table :zendesk_groups, :zendesk_src_groups
    rename_table :zendesk_macros, :zendesk_src_macros
    rename_table :zendesk_organizations, :zendesk_src_organizations
    rename_table :zendesk_tags, :zendesk_src_tags
    rename_table :zendesk_ticket_fields, :zendesk_src_ticket_fields
    rename_table :zendesk_users, :zendesk_src_users
    rename_table :pt_activities, :pt_src_activities
    rename_table :pt_iterations, :pt_src_iterations
    rename_table :pt_memberships, :pt_src_memberships
    rename_table :pt_notes, :pt_src_notes
    rename_table :pt_projects, :pt_src_projects
    rename_table :pt_stories, :pt_src_stories
    rename_table :pt_tasks, :pt_src_tasks
  end

  def self.down
    rename_table :site_src_trackings	, :site_trackings
    rename_table :mixpanel_src_events	, :mixpanel_events
    rename_table :mixpanel_src_event_properties	, :mixpanel_event_properties
    rename_table :mixpanel_src_funnels	, :mixpanel_funnels
    rename_table :mixpanel_src_funnel_properties	, :mixpanel_funnel_properties
    rename_table :harvest_src_clients	, :harvest_clients
    rename_table :harvest_src_contacts	, :harvest_contacts
    rename_table :harvest_src_expense_categories	, :harvest_expense_categories
    rename_table :harvest_src_expenses	, :harvest_expenses
    rename_table :harvest_src_invoice_categories	, :harvest_invoice_categories
    rename_table :harvest_src_invoice_messages	, :harvest_invoice_messages
    rename_table :harvest_src_invoice_payments	, :harvest_invoice_payments
    rename_table :harvest_src_invoices	, :harvest_invoices
    rename_table :harvest_src_people	, :harvest_people
    rename_table :harvest_src_projects	, :harvest_projects
    rename_table :harvest_src_task_assignments	, :harvest_task_assignments
    rename_table :harvest_src_tasks	, :harvest_tasks
    rename_table :harvest_src_timesheets	, :harvest_timesheets
    rename_table :harvest_src_user_assignments	, :harvest_user_assignments
    rename_table :ga_src_accounts	, :ga_accounts
    rename_table :ga_src_goals	, :ga_goals
    rename_table :ga_src_profiles	, :ga_profiles
    rename_table :ga_src_segments	, :ga_segments
    rename_table :ga_src_web_properties	, :ga_web_properties
    rename_table :zendesk_src_entries	, :zendesk_entries
    rename_table :zendesk_src_forums	, :zendesk_forums
    rename_table :zendesk_src_groups	, :zendesk_groups
    rename_table :zendesk_src_macros	, :zendesk_macros
    rename_table :zendesk_src_organizations	, :zendesk_organizations
    rename_table :zendesk_src_tags	, :zendesk_tags
    rename_table :zendesk_src_ticket_fields	, :zendesk_ticket_fields
    rename_table :zendesk_src_users	, :zendesk_users
    rename_table :pt_src_activities	, :pt_activities
    rename_table :pt_src_iterations	, :pt_iterations
    rename_table :pt_src_memberships	, :pt_memberships
    rename_table :pt_src_notes	, :pt_notes
    rename_table :pt_src_projects	, :pt_projects
    rename_table :pt_src_stories	, :pt_stories
    rename_table :pt_src_tasks	, :pt_tasks
  end
end

