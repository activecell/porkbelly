require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::Expense" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("expense_1")
      @xml_2 = ::Harvest::Util.load_fixture("expense_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("expense_1_changed")
      @params = {}
      @params[:mapper] = [[:srv_created_at	,'created-at'],
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
      @params[:parent] = "expense"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_prj = ::Harvest::Util.load_fixture("project_1")
      @xml_2_prj = ::Harvest::Util.load_fixture("project_2")
      
      @xml_1_ex = ::Harvest::Util.load_fixture("expense_category_1")
      @xml_2_ex = ::Harvest::Util.load_fixture("expense_category_2")
      
      @xml_1_usr = ::Harvest::Util.load_fixture("user_1")
      @xml_2_usr = ::Harvest::Util.load_fixture("user_2")
      
      @xml_1_cl = ::Harvest::Util.load_fixture("client_1")
      @xml_2_cl = ::Harvest::Util.load_fixture("client_2")      
#      reset tables
      Project.destroy_all
      ExpenseCategory.destroy_all
      User.destroy_all
#      fill data to source table
      record = ::Harvest::Expense.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Expense.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      ------------------
      record = ::Harvest::Project.find_or_initialize_by_target_id("1")
      record.content = @xml_1_prj
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Project.find_or_initialize_by_target_id("2")
      record.content = @xml_2_prj
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      ------------------
      record = ::Harvest::ExpenseCategory.find_or_initialize_by_target_id("1")
      record.content = @xml_1_ex
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::ExpenseCategory.find_or_initialize_by_target_id("2")
      record.content = @xml_2_ex
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      ------------------
      record = ::Harvest::User.find_or_initialize_by_target_id("1")
      record.content = @xml_1_usr
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::User.find_or_initialize_by_target_id("2")
      record.content = @xml_2_usr
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      ------------------
      record = ::Harvest::Client.find_or_initialize_by_target_id("1")
      record.content = @xml_1_cl
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Client.find_or_initialize_by_target_id("2")
      record.content = @xml_2_cl
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      --------
      Parser.parse_all Client 
      Parser.parse_all Project    
      Parser.parse_all ExpenseCategory 
      Parser.parse_all User 
    end

    it "should update data to table when same target_id" do
#      reset table
      Expense.destroy_all
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      Expense.update_data(arr_obj)
      obj_1 = Expense.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Expense.update_data(arr_obj)
        obj_2 = Expense.find_by_target_id("1")
#        compariation
        obj_1.total_cost.should == "12.0"
        obj_2.total_cost.should == "0.0"
#        check relationship
        obj_1.project.name.should == "This is a new project"
        obj_1.user.first_name.should == "An"
        obj_1.expense_category.name.should == "Mileage"
#        check count of record, should unchange
      end.should change(Expense, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Expense.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Expense.update_data(arr_obj)
        obj_1 = Expense.find_by_target_id("2")
        obj_1.total_cost.should == "30.0"
#        check relationship
        obj_1.project.name.should == "Second project"
        obj_1.user.first_name.should == "Second"
        obj_1.expense_category.name.should == "Meals"
#      check count of record, should increase by 1
      end.should change(Expense, :count).by(1)
    end

    it "should get data from source table correctly" do
      Expense.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Expense)
        obj_1 = Expense.find_by_target_id("2")
        obj_1.total_cost.should == "30.0"
#         check relationship
        obj_1.project.name.should == "Second project"
        obj_1.user.first_name.should == "Second"
        obj_1.expense_category.name.should == "Meals"
      end.should change(Expense, :count).by(2)
    end
  end
end

