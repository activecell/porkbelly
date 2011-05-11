module BusinessDomain
  module Zendesk
    class User < Base

#      has_many :entries
#      has_many :posts

      def self.table_name
        "zendesk_users"
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
        params.update :mapper => [[:srv_created_at,'created-at'],
                                  [:details,'details'],
                                  [:external_id,'external-id'],
                                  [:target_id,'id'],
                                  [:is_active,'is-active'],
                                  [:last_login,'last-login'],
                                  [:locale_id,'locale-id'],
                                  [:name,'name'],
                                  [:notes,'notes'],
                                  [:openid_url,'openid-url'],
                                  [:organization_id,'organization-id'],
                                  [:phone,'phone'],
                                  [:restriction_id,'restriction-id'],
                                  [:roles,'roles'],
                                  [:time_zone,'time-zone'],
                                  [:updated_at,'updated-at'],
                                  [:uses_12_hour_clock,'uses-12-hour-clock'],
                                  [:email,'email'],
                                  [:is_verified,'is-verified'],
                                  [:photo_url,'photo-url']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

