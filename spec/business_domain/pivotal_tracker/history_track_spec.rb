require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::History_Track" do

  describe "Update Data Method" do
    before :all do
      @xml_1_changed = ::Pivotal::Util.load_fixture("activity_1_changed")
      @params = {}
      @params[:mapper] = [[:story_type,'stories/story/story_type'],
                          [:estimate,'stories/story/estimate'],
                          [:current_state,'stories/story/current_state'],
                          [:description,'stories/story/description'],
                          [:name,'stories/story/name'],
                          [:requested_by,'stories/story/requested_by'],
                          [:owned_by,'stories/story/owned_by'],
                          [:labels,'stories/story/labels'],
                          [:note_id,'stories/story/notes/note/id'],
                          [:story_id,'stories/story/id'],
                          [:activity_id,'id'],
                          [:accepted_at,'stories/story/accepted_at']]
      @params[:parent] = "activity"
      @params[:key_field] = :activity_id

#      fill data to source table
      @xml_1 = ::Pivotal::Util.load_fixture("story_1")
      @xml_2 = ::Pivotal::Util.load_fixture("story_2")
      record = ::PivotalTracker::Story.find_or_initialize_by_target_id("6256883")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Story.find_or_initialize_by_target_id("6256943")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      @xml_1 = ::Pivotal::Util.load_fixture("activity_1")
      @xml_2 = ::Pivotal::Util.load_fixture("activity_2")
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
      Activity.destroy_all
      Story.destroy_all
      History_Track.destroy_all
      Parser.parse_all(Activity)
      Parser.parse_all(Story)
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      History_Track.update_data(arr_obj)
      obj_1 = History_Track.find(:first)
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        History_Track.update_data(arr_obj)
        obj_2 = History_Track.find(:last)
#       compariation
        obj_1.current_state.should == "accepted"
        obj_2.current_state.should == "changed current state"
#      check count of record, should unchange
      end.should change(History_Track, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      History_Track.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        History_Track.update_data(arr_obj)
        obj_1 = History_Track.find(:first)
        obj_1.current_state.should == "accepted"
#      check count of record, should increase by 1
      end.should change(History_Track, :count).by(1)
    end

    it "should get data from source table correctly" do
      History_Track.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(History_Track)
      end.should change(History_Track, :count).by(2)
    end
  end
end

