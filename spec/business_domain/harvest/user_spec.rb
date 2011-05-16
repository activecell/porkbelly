require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::User" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("user_1")
      @xml_2 = ::Harvest::Util.load_fixture("user_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("user_1_changed")
      @params = {}
      @params[:mapper] = [[:first_timer	,'first-timer'],
                          [:srv_created_at	,'created-at'],
                          [:has_access_to_all_future_projects	,'has-access-to-all-future-projects'],
                          [:preferred_approval_screen	,'preferred-approval-screen'],
                          [:preferred_project_status_reports_screen	,'preferred-project-status-reports-screen'],
                          [:wants_newsletter	,'wants-newsletter'],
                          [:twitter_username	,'twitter-username'],
                          [:default_expense_category_id	,'default-expense-category-id'],
                          [:default_task_id	,'default-task-id'],
                          [:default_time_project_id	,'default-time-project-id'],
                          [:is_contractor	,'is-contractor'],
                          [:preferred_entry_method	,'preferred-entry-method'],
                          [:srv_updated_at	,'updated-at'],
                          [:target_id	,'id'],
                          [:timezone	,'timezone'],
                          [:duplicate_timesheet_wants_notes	,'duplicate-timesheet-wants-notes'],
                          [:is_admin	,'is-admin'],
                          [:opensocial_identifier	,'opensocial-identifier'],
                          [:cache_version	,'cache-version'],
                          [:default_hourly_rate	,'default-hourly-rate'],
                          [:is_active	,'is-active'],
                          [:last_name	,'last-name'],
                          [:wants_timesheet_duplication	,'wants-timesheet-duplication'],
                          [:default_expense_project_id	,'default-expense-project-id'],
                          [:email_after_submit	,'email-after-submit'],
                          [:telephone	,'telephone'],
                          [:department	,'department'],
                          [:identity_url	,'identity-url'],
                          [:email	,'email'],
                          [:first_name	,'first-name']]
      @params[:parent] = "user"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Harvest::User.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::User.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      
    end

    it "should update data to table when same target_id" do
#      reset table
         User.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
         User.update_data(arr_obj)
        obj_1 =  User.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
         User.update_data(arr_obj)
        obj_2 =  User.find_by_target_id("1")
#      compariation
        obj_1.first_name.should == "An"
        obj_2.first_name.should == "Changed"
#      check count of record, should unchange
      end.should change( User, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
       User.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
         User.update_data(arr_obj)
        obj_1 =  User.find_by_target_id("2")
        obj_1.first_name.should == "Second"
#      check count of record, should increase by 1
      end.should change( User, :count).by(1)
    end

    it "should get data from source table correctly" do
       User.destroy_all
#      get data and update
      lambda do
        Parser.parse_all( User)
      obj_1 =  User.find_by_target_id("2")
      obj_1.first_name.should == "Second"
      end.should change( User, :count).by(2)
    end
  end
end

