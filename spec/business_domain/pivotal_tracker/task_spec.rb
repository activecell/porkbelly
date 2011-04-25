require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Task" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Pivotal::Util.load_fixture("task_1")
      @xml_2 = ::Pivotal::Util.load_fixture("task_2")
      @xml_1_changed = ::Pivotal::Util.load_fixture("task_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id,'id'],
                          [:description,'description'],
                          [:position,'position'],
                          [:complete,'complete'],
                          [:srv_created_at,'created_at']]
      @params[:parent] = "task"
      @params[:change] = [:story_id,:story_id]
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::PivotalTracker::Task.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.story_id = 1
      record.update_attributes(record)
      record = ::PivotalTracker::Task.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.story_id = 2
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do

        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Task.update_data(arr_obj)
        obj_1 = Task.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Task.update_data(arr_obj)
        obj_2 = Task.find_by_target_id("1")
#      compariation
        obj_1.description.should == "find shields1"
        obj_2.description.should == "changed description"
#      check count of record, should unchange
      end.should change(Task, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Task.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Task.update_data(arr_obj)
        obj_1 = Task.find_by_target_id("2")
        obj_1.description.should == "find shields2"
#      check count of record, should increase by 1
      end.should change(Task, :count).by(1)
    end

    it "should get data from source table correctly" do
      Task.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Task)
      obj_1 = Task.find_by_target_id("2")
      obj_1.story_id.should == "2"
      end.should change(Task, :count).by(2)
    end
  end
end

