class CreateParsedGaEntries < ActiveRecord::Migration
  def self.up
    create_table :ga_entries do |t|
      t.column	:visitorType	,:text
      t.column	:date	,:text
      t.column	:referralPath	,:text
      t.column	:campaign	,:text
      t.column	:source	,:text
      t.column	:hostname	,:text
      t.column	:pagePath	,:text
      t.column	:visitors	,:text
      t.column	:visits	,:text
      t.column	:pageviews	,:text
      t.column	:pageviewsPerVisit	,:text
      t.column	:uniquePageviews	,:text
      t.column	:avgTimeOnPage	,:text
      t.column	:avgTimeOnSite	,:text
      t.column	:entrances	,:text
      t.column	:exits	,:text
      t.column	:organicSearches	,:text
      t.column	:impressions	,:text
      t.column	:adClicks	,:text
      t.column	:adCost	,:text
      t.column	:CPM	,:text
      t.column	:CPC	,:text
      t.column	:CTR	,:text
      t.column	:costPerGoalConversion	,:text
      t.column	:costPerTransaction	,:text
      t.column	:costPerConversion	,:text
      t.column	:RPC	,:text
      t.column  :account_id, :integer, :null => false
      t.column  :profile_id,:integer
      t.timestamps
      
    end
  end

  def self.down
    drop_table :ga_entries
  end
end

