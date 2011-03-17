class ChangePivotalRequestUrlToText < ActiveRecord::Migration
  def self.up    
    [ :pt_activities,
      :pt_iterations,
      :pt_memberships,
      :pt_notes,
      :pt_projects,
      :pt_stories,
      :pt_tasks].each do |table_name|
        change_table table_name do |t|
          t.change :request_url, :text
        end
    end
  end
end
