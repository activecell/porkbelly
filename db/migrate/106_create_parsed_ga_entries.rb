class CreateParsedGaEntries < ActiveRecord::Migration
  def self.up
    create_table :ga_entries do |t|
      t.column	:visitorType	,:string
      t.column	:date	,:string
      t.column	:referralPath	,:string
      t.column	:campaign	,:string
      t.column	:source	,:string
      t.column	:hostname	,:string
      t.column	:pagePath	,:string
      t.column	:visitors	,:string
      t.column	:visits	,:string
      t.column	:pageviews	,:string
      t.column	:pageviewsPerVisit	,:string
      t.column	:uniquePageviews	,:string
      t.column	:avgTimeOnPage	,:string
      t.column	:avgTimeOnSite	,:string
      t.column	:entrances	,:string
      t.column	:exits	,:string
      t.column	:organicSearches	,:string
      t.column	:impressions	,:string
      t.column	:adClicks	,:string
      t.column	:adCost	,:string
      t.column	:CPM	,:string
      t.column	:CPC	,:string
      t.column	:CTR	,:string
      t.column	:costPerGoalConversion	,:string
      t.column	:costPerTransaction	,:string
      t.column	:costPerConversion	,:string
      t.column	:RPC	,:string
      t.column  :account_id, :integer, :null => false
      t.column  :profile_id,:integer
      t.timestamps
      
    end
  end

  def self.down
    drop_table :ga_entries
  end
end

