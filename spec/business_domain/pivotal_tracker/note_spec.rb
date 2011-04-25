require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Note" do

  describe "Update Data Method" do
    before :all do
#      using fixture of activity to parse note
      @xml_1 = ::Pivotal::Util.load_fixture("activity_1")
      @xml_2 = ::Pivotal::Util.load_fixture("activity_2")
      @xml_1_changed = ::Pivotal::Util.load_fixture("activity_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id,'stories/story/notes/note/id'],
                          [:text,'stories/story/notes/note/text'],
                          [:author,'author'],
                          [:noted_at,'occurred_at']]
      @params[:parent] = "/activity"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::PivotalTracker::Activity.find_or_initialize_by_target_id("5681005")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Activity.find_or_initialize_by_target_id("567890")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do

        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Note.update_data(arr_obj)
        obj_1 = Note.find_or_initialize_by_target_id("5681005")
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Note.update_data(arr_obj)
        obj_2 = Note.find_or_initialize_by_target_id("5681005")
#      compariation
        obj_1.text.should == "Comment 2"
        obj_2.text.should == "text changed"
#      check count of record, should unchange
      end.should change(Note, :count).by(0)
    end

    it "should insert data when new target_id" do
#      delete duplicated row
      Note.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Note.update_data(arr_obj)
        obj_1 = Note.find_or_initialize_by_target_id("567890")
        obj_1.text.should == "This is a comment"
#      check count of record, should increase by 1
      end.should change(Note, :count).by(1)
    end

    it "should get data from source table correctly" do
      Note.destroy_all
#       get data and update
      lambda do
        Parser.parse_all(Note)
      end.should change(Note, :count).by(2)
    end
  end
end

