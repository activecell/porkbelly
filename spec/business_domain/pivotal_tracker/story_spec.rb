require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Story" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Pivotal::Util.load_fixture("story_1")
      @xml_2 = ::Pivotal::Util.load_fixture("story_2")
      @xml_1_changed = ::Pivotal::Util.load_fixture("story_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id,'id'],
                    [:project_id,'project_id'],
                    [:story_type,'story_type'],
                    [:url,'url'],
                    [:estimate,'estimate'],
                    [:current_state,'current_state'],
                    [:description,'description'],
                    [:name,'name'],
                    [:requested_by,'requested_by'],
                    [:owned_by,'owned_by'],
                    [:srv_created_at,'created_at'],
                    [:srv_updated_at,'updated_at'],
                    [:labels,'labels']]
      @params[:parent] = "story"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::PivotalTracker::Story.find_or_initialize_by_target_id("6256883")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Story.find_or_initialize_by_target_id("6256943")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do

        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Story.update_data(arr_obj)
        obj_1 = Story.find_by_target_id("9963685")
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Story.update_data(arr_obj)
        obj_2 = Story.find_by_target_id("9963685")
#      compariation
        obj_1.description.should == "test desc"
        obj_2.description.should == "Changed Description"
#      check count of record, should unchange
      end.should change(Story, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Story.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Story.update_data(arr_obj)
        obj_1 = Story.find_by_target_id("9963419")
        obj_1.requested_by.should == "Le Trong TIn"
#      check count of record, should increase by 1
      end.should change(Story, :count).by(1)
    end

    it "should get data from source table correctly" do
      Story.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Story)
      end.should change(Story, :count).by(2)
    end
  end
end

