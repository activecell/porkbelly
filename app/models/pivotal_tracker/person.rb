module BusinessDomain
  module PivotalTracker
    class Person < Base

      has_many :memberships
      has_many :projects, :through => :memberships

      def self.table_name
          "pt_persons"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Membership
      end

      def self.filter_params
        params = {}
        params.update :parent => '/membership/person'
        params.update :mapper => [[:email,'email'],
                                  [:name,'name'],
                                  [:initials,'initials']]
        params.update :key_field => :email
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              object = self.find_or_initialize_by_email(o[:email])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

