require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Activity" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Pivotal::Util.load_fixture("activity_1")
      @xml_2 = ::Pivotal::Util.load_fixture("activity_2")
      @xml_1_changed = ::Pivotal::Util.load_fixture("activity_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id,'id'],
          [:version,'version'],
          [:event_type,'event_type'],
          [:occurred_at,'occurred_at'],
          [:author,'author'],
          [:project_id, 'project_id'],
          [:description,'description']]
      @params[:parent] = "activity"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::PivotalTracker::Activity.find_or_initialize_by_target_id("59596685")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Activity.find_or_initialize_by_target_id("59596663")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Activity.update_data(arr_obj)
        obj_1 = Activity.find_or_initialize_by_target_id("59596685")
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Activity.update_data(arr_obj)
        obj_2 = Activity.find_or_initialize_by_target_id("59596685")
#       compariation
        obj_1.description.should == "Chuong Huynh accepted \"Can't create issue for iteration\""
        obj_2.description.should == "Changed description"
#      check count of record, should unchange
      end.should change(Activity, :count).by(0)

    end

    it "should insert data when new target_id" do
#      reset table
      Activity.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Activity.update_data(arr_obj)
        obj_1 = Activity.find_by_target_id("59596663")
        obj_1.description.should == "Chuong Huynh accepted \"Include a free text \"Summary\" field in daily report\""
#      check count of record, should increase by 1
      end.should change(Activity, :count).by(1)
    end

    it "should get data from source table correctly" do
      Activity.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Activity)
      end.should change(Activity, :count).by(2)
    end
  end
end

