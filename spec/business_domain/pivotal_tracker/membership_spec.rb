require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Membership" do

  describe "Update Data Method" do
    before :all do

      @xml_1_changed = ::Pivotal::Util.load_fixture("membership_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id,'id'],
                          [:role,'role'],
                          [:project_id,'project/id'],
                          [:person_id,'person/email']]
      @params[:parent] = '/membership'
      @params[:key_field] = :target_id

#      fill data to source table
      @xml_1 = ::Pivotal::Util.load_fixture("project_1")
      @xml_2 = ::Pivotal::Util.load_fixture("project_2")
      record = ::PivotalTracker::Project.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Project.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      @xml_1 = ::Pivotal::Util.load_fixture("membership_1")
      @xml_2 = ::Pivotal::Util.load_fixture("membership_2")
      record = ::PivotalTracker::Membership.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
      record = ::PivotalTracker::Membership.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'd0f12bb1ac3d8f1867278620dda90dbb'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#        reset table
        Membership.destroy_all
        Person.destroy_all
        Project.destroy_all
        Parser.parse_all(Person)
        Parser.parse_all(Project)
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Membership.update_data(arr_obj)
        obj_1 = Membership.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Membership.update_data(arr_obj)
        obj_2 = Membership.find_by_target_id("1")
#       compariation
        obj_1.role.should == "Owner"
        obj_2.role.should == "Role changed"
#        check count of record, should unchange
      end.should change(Membership, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Membership.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Membership.update_data(arr_obj)
        obj_1 = Membership.find_by_target_id("2")
        obj_1.role.should == "Member"
#      check count of record, should increase by 1
      end.should change(Membership, :count).by(1)
    end

    it "should get data from source table correctly" do
      Membership.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Membership)
      end.should change(Membership, :count).by(2)
    end
  end
end

