module BusinessDomain
  module Harvest
    class Expense < Base

      belongs_to :project
      belongs_to :user
      belongs_to :expense_category

      def self.table_name
        "harvest_expenses"
      end

      ######################
      #      override method
      ######################

      def self.src_data
        return ::Harvest::Expense
      end

      def self.filter_params
        params = {}
        params.update :parent =>'/expense'
        params.update :mapper => [[:srv_created_at	,'created-at'],
                                  [:is_billed	,'is-billed'],
                                  [:notes	,'notes'],
                                  [:project_id	,'project-id'],
                                  [:srv_updated_at	,'updated-at'],
                                  [:spent_at	,'spent-at'],
                                  [:units	,'units'],
                                  [:target_id	,'id'],
                                  [:is_closed	,'is-closed'],
                                  [:user_id	,'user-id'],
                                  [:expense_category_id	,'expense-category-id'],
                                  [:total_cost	,'total-cost'],
                                  [:has_receipt	,'has-receipt'],
                                  [:receipt_url	,'receipt-url']]
        params.update :key_field => :target_id
        return params
      end
      
      def self.update_data(arr_obj)
        transaction do
          arr_obj.each do |arr_ele|
            arr_ele.each do |o|
              project = Project.find_by_target_id(o[:project_id])
              user = User.find_by_target_id(o[:user_id])
              expense_category = ExpenseCategory.find_by_target_id(o[:expense_category_id])
              
              o.update :project_id => project[:id]
              o.update :user_id => user[:id]
              o.update :expense_category_id => expense_category[:id]
              
              object = self.find_or_initialize_by_target_id(o[:target_id])
              object.update_attributes(o)
            end unless arr_ele.nil?
          end
        end
      end
    end
  end
end

