module BusinessDomain
  module GA
    class All
      def self.parse_all
        Parser.parse_all(Project)
        Parser.parse_all(Entry)
      end
    end
  end
end

