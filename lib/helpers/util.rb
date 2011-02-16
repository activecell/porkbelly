require 'csv'

module Util
  # Parse CSV file to hash object.
  def self.hash_from_csv(csv_file)
    rows = CSV.open(File.open(csv_file)).to_a
    col_headers = rows.shift
    col_headers.each do |h|
      h.strip!
    end
     
    collection = rows.collect do |row|
      Hash[*col_headers.zip(row.strip).flatten]
    end
    
    return collection
  end
end
