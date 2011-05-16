require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::TaskAssignment" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("task_assignment_1")
      @xml_2 = ::Harvest::Util.load_fixture("task_assignment_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("task_assignment_1_changed")
      @params = {}
      @params[:mapper] = [[:srv_created_at,'created-at'],
                          [:project_id,'project-id'],
                          [:srv_updated_at,'updated-at'],
                          [:hourly_rate,'hourly-rate'],
                          [:target_id,'id'],
                          [:task_id,'task-id'],
                          [:deactivated,'deactivated'],
                          [:is_project_manager,'is-project-manager'],
                          [:budget,'budget'],
                          [:estimate,'estimate']]
      @params[:parent] = "task-assignment"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_prj = ::Harvest::Util.load_fixture("project_1")
      @xml_2_prj = ::Harvest::Util.load_fixture("project_2")
      
      @xml_1_tsk = ::Harvest::Util.load_fixture("task_1")
      @xml_2_tsk = ::Harvest::Util.load_fixture("task_2")
      
      @xml_1_cl = ::Harvest::Util.load_fixture("client_1")
      @xml_2_cl = ::Harvest::Util.load_fixture("client_2")      
#      reset tables
      Project.destroy_all
      Task.destroy_all
      Client.destroy_all
#      fill data to source table
      record = ::Harvest::TaskAssignment.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::TaskAssignment.find_or_initialize_by_target_id("2")
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
    end

    it "should update data to table when same target_id" do
#      reset table
      TaskAssignment.destroy_all
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      TaskAssignment.update_data(arr_obj)
      obj_1 = TaskAssignment.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        TaskAssignment.update_data(arr_obj)
        obj_2 = TaskAssignment.find_by_target_id("1")
#        compariation
        obj_1.deactivated.should == "false"
        obj_2.deactivated.should == "true"
#        check relationship
        obj_1.project.name.should == "This is a new project"
        obj_1.task.name.should == "Vacation"
#        check count of record, should unchange
      end.should change(TaskAssignment, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      TaskAssignment.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        TaskAssignment.update_data(arr_obj)
        obj_1 = TaskAssignment.find_by_target_id("2")
        obj_1.deactivated.should == "false"
#        check relationship
        obj_1.project.name.should == "Second project"
        obj_1.task.name.should == "Second task"
#      check count of record, should increase by 1
      end.should change(TaskAssignment, :count).by(1)
    end

    it "should get data from source table correctly" do
      TaskAssignment.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(TaskAssignment)
        obj_1 = TaskAssignment.find_by_target_id("2")
        obj_1.deactivated.should == "false"
#         check relationship
        obj_1.project.name.should == "Second project"
        obj_1.task.name.should == "Second task"
      end.should change(TaskAssignment, :count).by(2)
    end
  end
end

