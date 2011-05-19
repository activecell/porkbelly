module BusinessDomain
  module Harvest
    class Client < Base

      has_many :invoices
      has_many :contacts
      has_many :projects

      def self.table_name
        "harvest_clients"
      end

######################
#      override method
######################
      def self.src_data
        return ::Harvest::Client
      end

      def self.filter_params
        params = {}
        params.update :parent => '/client'
        params.update :mapper => [[:name	,'name'],
                                  [:srv_created_at	,'created-at'],
                                  [:details	,'details'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:highrise_id	,'highrise-id'],
                                  [:target_id	,'id'],
                                  [:cache_version	,'cache-version'],
                                  [:default_invoice_timeframe	,'default-invoice-timeframe'],
                                  [:currency	,'currency'],
                                  [:active	,'active'],
                                  [:currency_symbol	,'currency-symbol']]
        params.update :key_field => :target_id
        return params
      end
    end
  end
end

