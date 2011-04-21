module BusinessDomain
  module PivotalTracker
    class Person < Base

      has_many :memberships
      has_many :projects, :through => :memberships

      def self.table_name
          "pt_persons"
      end

#     override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Membership
        transaction do
          arr_obj = []
          @@src_data.find(:all).each do |o|
            arr_obj.push parse(o.content)
          end
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = find_or_initialize_by_email(o[:email])
              object.update_attributes(o)
            end
          end
        end
      end

      protected

#     override method
      def self.parse_content(content)
        @@params = [[:email,'email'],[:name,'name'],[:initials,'initials']]
        @@parent = '/membership/person'
        super(content)
      end

    end
  end
end

