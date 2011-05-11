require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Organization" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("organization_1")
      @xml_2 = ::Zendesk::Util.load_fixture("organization_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("organization_1_changed")
      @params = {}
      @params[:mapper] = [[:srv_created_at,'created-at'],
                          [:group_id,'group-id'],
                          [:target_id,'id'],
                          [:is_shared,'is-shared'],
                          [:is_shared_comments,'is-shared-comments'],
                          [:name,'name'],
                          [:notes,'notes'],
                          [:srv_updated_at,'updated-at']]
      @params[:parent] = "organization"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::Organization.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/organizations.xml'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Zendesk::Organization.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/organizations.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        Organization.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Organization.update_data(arr_obj)
        obj_1 = Organization.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Organization.update_data(arr_obj)
        obj_2 = Organization.find_by_target_id("1")
#      compariation
        obj_1.name.should == "utwkidvn"
        obj_2.name.should == "Name be changed"
#      check count of record, should unchange
      end.should change(Organization, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Organization.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Organization.update_data(arr_obj)
        obj_1 = Organization.find_by_target_id("2")
        obj_1.name.should == "this is an organization"
#      check count of record, should increase by 1
      end.should change(Organization, :count).by(1)
    end

    it "should get data from source table correctly" do
      Organization.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Organization)
      obj_1 = Organization.find_by_target_id("2")
      obj_1.name.should == "this is an organization"
      end.should change(Organization, :count).by(2)
    end
  end
end

