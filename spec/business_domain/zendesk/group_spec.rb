require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Group" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("group_1")
      @xml_2 = ::Zendesk::Util.load_fixture("group_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("group_1_changed")
      @params = {}
      @params[:mapper] = [[:srv_created_at,'created-at'],
                          [:target_id,'id'],
                          [:is_active,'is-active'],
                          [:name,'name'],
                          [:srv_updated_at,'updated-at']]
      @params[:parent] = "group"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::Group.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/groups.xml'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Zendesk::Group.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/groups.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        Group.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Group.update_data(arr_obj)
        obj_1 = Group.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Group.update_data(arr_obj)
        obj_2 = Group.find_by_target_id("1")
#      compariation
        obj_1.name.should == "Support"
        obj_2.name.should == "Support for something"
#      check count of record, should unchange
      end.should change(Group, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Group.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Group.update_data(arr_obj)
        obj_1 = Group.find_by_target_id("2")
        obj_1.name.should == "Developers"
#      check count of record, should increase by 1
      end.should change(Group, :count).by(1)
    end

    it "should get data from source table correctly" do
      Group.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Group)
      obj_1 = Group.find_by_target_id("2")
      obj_1.name.should == "Developers"
      end.should change(Group, :count).by(2)
    end
  end
end

