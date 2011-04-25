require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Iteration_Story" do

  describe "Update Data Method" do
    before :all do
      @params = {}
      @params[:mapper] = [[:iteration_id,'id'],[:arr_story_id,'stories//story']]
      @params[:parent] = "iteration"
      @params[:key_field] = :iteration_id
      @params[:be_array] = [:arr_story_id,'id']

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
      @xml_1 = ::Pivotal::Util.load_fixture("iteration_1")
      @xml_2 = ::Pivotal::Util.load_fixture("iteration_2")
      record = ::PivotalTracker::Iteration.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Iteration.find_or_initialize_by_target_id("12")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
    end

    it "should insert data when get new story" do

      Iteration.destroy_all
      Story.destroy_all
      Iteration_Story.destroy_all
      Parser.parse_all(Iteration)
      Parser.parse_all(Story)
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Iteration_Story.update_data(arr_obj)
#      check count of record, should increase by 1
      end.should change(Iteration_Story, :count).by(1)
    end

    it "should get data from source table correctly" do
      Iteration_Story.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Iteration_Story)
      end.should change(Iteration_Story, :count).by(2)
    end
  end
end

