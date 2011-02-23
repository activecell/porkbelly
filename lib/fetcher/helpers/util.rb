require 'csv'
require 'cgi'
require 'uri'

module Helpers
  module Util
    # Parse CSV file to hash object.
    def self.hash_from_csv(csv_file)
      rows = ::CSV.open(File.open(csv_file)).to_a
      col_headers = rows.shift
      col_headers.each do |h|
        h.strip!
      end
       
      collection = rows.collect do |row|
        row.each{|cell| cell.strip!}
        Hash[*col_headers.zip(row).flatten]
      end
      
      return collection
    end
    
    # Parse query string (ex: "interval=7&expire=127562496&test=1") to hash object.
    # Return nil if cannot parse
    def self.hash_from_query_string!(query_string)
      # Parse query string to hash.
      params_hash = ::CGI.parse(query_string)
      
      # Re-format the hash.
      # Because the current values are not very correct 
      # (ex: params_hash = {"interval"=>["7"], "expire"=>["127562496"], "test"=>["1"]}
      params_hash.each do |k, v|
        if v.is_a?(Array)
          params_hash[k] = v[0]
        end
      end
      
      return params_hash
    rescue Exception
      return nil
    end
  end
end
