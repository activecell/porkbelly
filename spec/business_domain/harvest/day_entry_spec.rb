require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::DayEntry" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("daily_1")
      @xml_2 = ::Harvest::Util.load_fixture("daily_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("daily_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id	,'id'],
                            [:spent_at	,'spent_at'],
                            [:user_id	,'user_id'],
                            [:client	,'client'],
                            [:project_id	,'project_id'],
                            [:srv_project	,'project'],
                            [:task_id	,'task_id'],
                            [:srv_task	,'task'],
                            [:hours	,'hours'],
                            [:notes	,'notes'],
                            [:srv_created_at	,'created_at'],
                            [:srv_updated_at	,'updated_at'],
                            [:timer_started_at	,'timer_started_at']]
      @params[:parent] = "/daily/day_entries//day_entry"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_prj = ::Harvest::Util.load_fixture("project_1")
      @xml_2_prj = ::Harvest::Util.load_fixture("project_2")
      
      @xml_1_tsk = ::Harvest::Util.load_fixture("task_1")
      @xml_2_tsk = ::Harvest::Util.load_fixture("task_2")
      
      @xml_1_cl = ::Harvest::Util.load_fixture("client_1")
      @xml_2_cl = ::Harvest::Util.load_fixture("client_2")      
      
      @xml_1_usr = ::Harvest::Util.load_fixture("user_1")
      @xml_2_usr = ::Harvest::Util.load_fixture("user_2")
#      reset tables
      Project.destroy_all
      Task.destroy_all
      User.destroy_all
      Client.destroy_all
#      fill data to source table
      record = ::Harvest::Timesheet.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Timesheet.find_or_initialize_by_target_id("2")
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
      record = ::Harvest::Task.find_or_initialize_by_target_id("1")
      record.content = @xml_1_tsk
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Task.find_or_initialize_by_target_id("2")
      record.content = @xml_2_tsk
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
      Parser.parse_all Task 
      Parser.parse_all User
    end

    it "should update data to table when same target_id" do
#      reset table
      DayEntry.destroy_all
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      DayEntry.update_data(arr_obj)
      obj_1 = DayEntry.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        DayEntry.update_data(arr_obj)
        obj_2 = DayEntry.find_by_target_id("1")
#        compariation
        obj_1.notes.should == "Note for first"
        obj_2.notes.should == "Changed"
#        check relationship
        obj_1.project.name.should == "This is a new project"
        obj_1.task.name.should == "Vacation"
#        check count of record, should unchange
      end.should change(DayEntry, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      DayEntry.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        DayEntry.update_data(arr_obj)
        obj_1 = DayEntry.find_by_target_id("2")
        obj_1.notes.should == "Second entry"
#        check relationship
        obj_1.project.name.should == "Second project"
        obj_1.task.name.should == "Second task"
#      check count of record, should increase by 1
      end.should change(DayEntry, :count).by(1)
    end

    it "should get data from source table correctly" do
      DayEntry.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(DayEntry)
        obj_1 = DayEntry.find_by_target_id("2")
        obj_1.notes.should == "Second entry"
#         check relationship
        obj_1.project.name.should == "Second project"
        obj_1.task.name.should == "Second task"
      end.should change(DayEntry, :count).by(2)
    end
  end
end

