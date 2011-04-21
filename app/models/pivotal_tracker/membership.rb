module BusinessDomain
  module PivotalTracker
    class Membership < Base

      validates_uniqueness_of :person_id, :scope => :project_id
      belongs_to :person
      belongs_to :project



      def self.table_name
          "pt_memberships"
      end

#      override method
      def self.parse_all
        @@src_data = ::PivotalTracker::Membership
        super
      end

      protected

#      override method
      def self.parse_content(content)
#        project_id, person_id used for temporation
        @@params = [[:target_id,'id'],
        [:role,'role'],
        [:project_id,'project/id'],
        [:person_id,'person/email']]
        @@parent = '/membership'
        super(content)
#        update database
        @@contain[0][:person_id] = Person.find_by_email(@@contain[0][:person_id]).id
        @@contain[0][:project_id] = Project.find_by_target_id(@@contain[0][:project_id]).id
        @@contain
      end

    end
  end
end

