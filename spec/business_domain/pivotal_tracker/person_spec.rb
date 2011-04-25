require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::PivotalTracker

describe "::BusinessDomain::PivotalTracker::Person" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Pivotal::Util.load_fixture("membership_1")
      @xml_2 = ::Pivotal::Util.load_fixture("membership_2")
      @xml_1_changed = ::Pivotal::Util.load_fixture("membership_1_changed")
      @params = {}
      @params[:mapper] = [[:email,'email'],
                          [:name,'name'],
                          [:initials,'initials']]
      @params[:parent] = '/membership/person'
      @params[:key_field] = :email

#      fill data to source table
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

        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Person.update_data(arr_obj)
        obj_1 = Person.find_by_email("picard@earth.ufp")
#      second sample
      lambda do
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Person.update_data(arr_obj)
        obj_2 = Person.find_by_email("picard@earth.ufp")
#      compariation
        obj_1.name.should == "Jean-Luc Picard"
        obj_2.name.should == "name changed"
#      check count of record, should unchange
      end.should change(Person, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Person.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Person.update_data(arr_obj)
        obj_1 = Person.find_by_email("jadzia@trill.ufp")
        obj_1.name.should == "Jadzia Dax"
#      check count of record, should increase by 1
      end.should change(Person, :count).by(1)
    end

    it "should get data from source table correctly" do
      Person.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Person)
      end.should change(Person, :count).by(2)
    end
  end
end

