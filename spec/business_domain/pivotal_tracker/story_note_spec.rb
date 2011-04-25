require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Story_Note" do

  describe "Update Data Method" do
    before :all do
      @params = {}
      @params[:mapper] = [[:story_id,'id'],[:arr_note_id,'notes//note']]
      @params[:parent] = "story"
      @params[:key_field] = :story_id
      @params.update :be_array => [:arr_note_id,'id']

#      fill data to source table
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
    end

    it "should insert data when get new story" do

      Note.destroy_all
      Story.destroy_all
      Story_Note.destroy_all
      Parser.parse_all(Note)
      Parser.parse_all(Story)
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Story_Note.update_data(arr_obj)
#      check count of record, should increase by 1
      end.should change(Story_Note, :count).by(1)
    end

    it "should get data from source table correctly" do
      Story_Note.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Story_Note)
      end.should change(Story_Note, :count).by(2)
    end
  end
end

