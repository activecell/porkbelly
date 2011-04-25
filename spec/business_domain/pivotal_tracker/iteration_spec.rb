require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Iteration" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Pivotal::Util.load_fixture("iteration_1")
      @xml_2 = ::Pivotal::Util.load_fixture("iteration_2")
      @xml_1_changed = ::Pivotal::Util.load_fixture("iteration_1_changed")
      @params = {}
      @params[:mapper] =[[:target_id,'id'],
                        [:number,'number'],
                        [:start,'start'],
                        [:finish,'finish'],
                        [:team_strength,'team_strength']]
      @params[:parent] = "iteration"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::PivotalTracker::Iteration.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Iteration.find_or_initialize_by_target_id("12")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do

      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      Iteration.update_data(arr_obj)
      obj_1 = Iteration.find_or_initialize_by_target_id("1")
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Iteration.update_data(arr_obj)
        obj_2 = Iteration.find_or_initialize_by_target_id("1")
#       compariation
        obj_1.number.should == "1"
        obj_2.number.should == "3"
#      check count of record, should unchange
      end.should change(Iteration, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Iteration.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Iteration.update_data(arr_obj)
        obj_1 = Iteration.find_or_initialize_by_target_id("12")
        obj_1.number.should == "12"
#      check count of record, should increase by 1
      end.should change(Iteration, :count).by(1)
    end

    it "should get data from source table correctly" do
      Iteration.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Iteration)
      end.should change(Iteration, :count).by(2)
    end
  end
end

