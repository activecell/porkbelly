class CreateParsedZendeskUsers < ActiveRecord::Migration
  def self.up
    create_table :zendesk_users do |t|
      t.column	:srv_created_at	, :string
      t.column	:details	, :string
      t.column	:external_id	, :string
      t.column	:target_id	, :string	,:null => false
      t.column	:is_active	, :string
      t.column	:last_login	, :string
      t.column	:locale_id	, :string
      t.column	:name	, :string
      t.column	:notes	, :string
      t.column	:openid_url	, :string
      t.column	:organization_id	, :string
      t.column	:phone	, :string
      t.column	:restriction_id	, :string
      t.column	:roles	, :string
      t.column	:time_zone	, :string
      t.column	:updated_at	, :string
      t.column	:uses_12_hour_clock	, :string
      t.column	:email	, :string
      t.column	:is_verified	, :string
      t.column	:photo_url	, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :zendesk_users
  end
end

