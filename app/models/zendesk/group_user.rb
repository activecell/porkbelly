module BusinessDomain
  module Zendesk
    class GroupUser < Base

      belongs_to :group
      belongs_to :user

      def self.table_name
        "zendesk_group_users"
      end

######################
#      override method
######################
      def self.src_data
        return ::Zendesk::User
      end

      def self.filter_params
        params = {}
        params.update :parent => '/user'
        params.update :mapper => [[:arr_group_id,'groups//group']]
        params.update :change => [:user_id,:target_id]
        params.update :key_field => :arr_group_id
        params.update :be_array => [:arr_group_id,'id']
        return params
      end

      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              o[:arr_group_id].each do |n|
                user = User.find_by_target_id(o[:user_id].to_s)
                group = Group.find_by_target_id(n)
                if user.nil? or group.nil?
                  next
                end
                record = {}
                record[:user_id] = user[:id].to_s
                record[:group_id] = group[:id].to_s
                object = find_or_initialize_by_user_id_and_group_id(record[:user_id],record[:group_id])
                object.update_attributes(record)
              end
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

