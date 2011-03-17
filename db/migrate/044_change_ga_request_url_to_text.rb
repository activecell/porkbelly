class ChangeGaRequestUrlToText < ActiveRecord::Migration
  def self.up    
    [ :ga_accounts,
      :ga_goals,
      :ga_profiles,
      :ga_segments,
      :ga_web_properties].each do |table_name|
        change_table table_name do |t|
          t.change :request_url, :text
        end
    end
  end
end
