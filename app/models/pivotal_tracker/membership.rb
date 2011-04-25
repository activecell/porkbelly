module BusinessDomain
  module PivotalTracker
    class Membership < Base

      validates_uniqueness_of :person_id, :scope => :project_id
      belongs_to :person
      belongs_to :project



      def self.table_name
          "pt_memberships"
      end

######################
#      override method
######################
      def self.src_data
        return ::PivotalTracker::Membership
      end

      def self.filter_params
        params = {}
        params.update :parent => '/membership'
        params.update :mapper => [[:target_id,'id'],
                                  [:role,'role'],
                                  [:project_id,'project/id'],
                                  [:person_id,'person/email']]
        params.update :key_field => :target_id
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
#              convert to local id
              person = Person.find_by_email(o[:person_id]).id
              project = Project.find_by_target_id(o[:project_id]).id
              next if person.nil? or project.nil?
              o[:person_id] = person.id
              o[:project_id] = project.id
              object = find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

