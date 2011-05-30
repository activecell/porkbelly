module BusinessDomain
  module GA
    class All
      def self.parse_all
        Parser.parse_all(Profile, "SPEC")
        Parser.parse_all(Entry, "SPEC")
      end
    end
  end
end

