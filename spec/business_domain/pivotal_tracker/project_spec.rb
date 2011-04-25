require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Project" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Pivotal::Util.load_fixture("project_1")
      @xml_2 = ::Pivotal::Util.load_fixture("project_2")
      @xml_1_changed = ::Pivotal::Util.load_fixture("project_1_changed")
      @params = {}
      @params[:mapper] =[[:target_id ,'id'],
                        [:name ,'name'],
                        [:iteration_length ,'iteration_length'],
                        [:week_start_day ,'week_start_day'],
                        [:point_scale ,'point_scale'],
                        [:account ,'account'],
                        [:first_iteration_start_time ,'first_iteration_start_time'],
                        [:current_iteration_number ,'current_iteration_number'],
                        [:enable_tasks ,'enable_tasks'],
                        [:velocity_scheme ,'velocity_scheme'],
                        [:current_velocity ,'current_velocity'],
                        [:initial_velocity ,'initial_velocity'],
                        [:number_of_done_iterations_to_show ,'number_of_done_iterations_to_show'],
                        [:labels ,'labels'],
                        [:last_activity_at ,'last_activity_at'],
                        [:allow_attachments ,'allow_attachments'],
                        [:public ,'public'],
                        [:use_https ,'use_https'],
                        [:bugs_and_chores_are_estimatable ,'bugs_and_chores_are_estimatable'],
                        [:commit_mode ,'commit_mode']]
      @params[:parent] = "project"
      @params[:key_field] = :target_id
#      fill data to source table
      record = ::PivotalTracker::Project.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Project.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do

      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      Project.update_data(arr_obj)
      obj_1 = Project.find_or_initialize_by_target_id("1")
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Project.update_data(arr_obj)
        obj_2 = Project.find_or_initialize_by_target_id("1")
#       compariation
        obj_1.labels.should == "shields,transporter"
        obj_2.labels.should == "Changed label"
#      check count of record, should unchange
      end.should change(Project, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Project.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Project.update_data(arr_obj)
        obj_1 = Project.find_or_initialize_by_target_id("2")
        obj_1.labels.should == "my label"
#      check count of record, should increase by 1
      end.should change(Project, :count).by(1)
    end

    it "should get data from source table correctly" do
      Project.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Project)
      end.should change(Project, :count).by(2)
    end
  end
end

