require File.expand_path(File.join(File.dirname(__FILE__), "..", '..', 'config', 'database'))

module Salesforce
=begin
  Contains the metadata describing structure of an Salesforce object.
  'sf_object_metadata' tables's Schema:
    id:             int (primary key).
    credential:     string (authentication info use to retrieve the metadata).
    name:           string (name of the object).
    url:            string (the entry point to access the object).
    metadata:       text (full content of the object describing data).
    format:         string (format of the metadata info)
    created_at:     datetime
    updated_at:     datetime 
=end
  class ObjectMetaData < ActiveRecord::Base
    def self.table_name
      "sf_object_metadata"
    end
  end

=begin
  Contains data fetching from Salesforce.
  'sf_object_data' tables's Schema:
    id:             int (primary key)
    target_id:      string # unique ID from API services.
    content:        text
    request_url:    string
    format:         string
    credential:     string
    created_at:     datetime
    updated_at:     datetime  
=end
  class ObjectData < ActiveRecord::Base
    def self.table_name
      "sf_object_data"
    end
  end
end
