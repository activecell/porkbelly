require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::Project" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("project_1")
      @xml_2 = ::Harvest::Util.load_fixture("project_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("project_1_changed")
      @params = {}
      @params[:mapper] = [[:name ,'name'],
                          [:over_budget_notified_at ,'over-budget-notified-at'],
                          [:billable ,'billable'],
                          [:srv_created_at ,'created-at'],
                          [:earliest_record_at ,'earliest-record-at'],
                          [:show_budget_to_all ,'show-budget-to-all'],
                          [:code ,'code'],
                          [:cost_budget ,'cost-budget'],
                          [:notify_when_over_budget ,'notify-when-over-budget'],
                          [:srv_updated_at ,'updated-at'],
                          [:cost_budget_include_expenses ,'cost-budget-include-expenses'],
                          [:fees ,'fees'],
                          [:highrise_deal_id ,'highrise-deal-id'],
                          [:latest_record_at ,'latest-record-at'],
                          [:hourly_rate ,'hourly-rate'],
                          [:target_id ,'id'],
                          [:bill_by ,'bill-by'],
                          [:client_id ,'client-id'],
                          [:active_user_assignments_count ,'active-user-assignments-count'],
                          [:cache_version ,'cache-version'],
                          [:budget ,'budget'],
                          [:over_budget_notification_percentage ,'over-budget-notification-percentage'],
                          [:active ,'active'],
                          [:active_task_assignments_count ,'active-task-assignments-count'],
                          [:basecamp_id ,'basecamp-id'],
                          [:budget_by ,'budget-by'],
                          [:estimate ,'estimate'],
                          [:estimate_by ,'estimate-by'],
                          [:notes ,'notes'],
                          [:hint_earliest_record_at ,'hint-earliest-record-at'],
                          [:hint_latest_record_at ,'hint-latest-record-at']]
      @params[:parent] = "project"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_cl = ::Harvest::Util.load_fixture("client_1")
      @xml_2_cl = ::Harvest::Util.load_fixture("client_2")
#      reset tables
      Client.destroy_all
#      fill data to source table
      record = ::Harvest::Project.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Project.find_or_initialize_by_target_id("2")
      record.content = @xml_2
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
    end

    it "should update data to table when same target_id" do
#      reset table
      Project.destroy_all
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      Project.update_data(arr_obj)
      obj_1 = Project.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Project.update_data(arr_obj)
        obj_2 = Project.find_by_target_id("1")
#        compariation
        obj_1.name.should == "This is a new project"
        obj_2.name.should == "Changed"
#        check relationship
        obj_1.client.srv_created_at.should == "2011-02-21T04:51:52Z"
#        check count of record, should unchange
      end.should change(Project, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Project.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Project.update_data(arr_obj)
        obj_1 = Project.find_by_target_id("2")
        obj_1.name.should == "Second project"
#        check relationship
        obj_1.client.name.should == "This is a second client"        
#      check count of record, should increase by 1
      end.should change(Project, :count).by(1)
    end

    it "should get data from source table correctly" do
      Project.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Project)
        obj_1 = Project.find_by_target_id("2")
        obj_1.name.should == "Second project"
#         check relationship
        obj_1.client.name.should == "This is a second client" 
      end.should change(Project, :count).by(2)
    end
  end
end

