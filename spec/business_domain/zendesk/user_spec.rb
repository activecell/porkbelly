require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::User" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("user_1")
      @xml_2 = ::Zendesk::Util.load_fixture("user_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("user_1_changed")
      @params = {}
      @params[:mapper] = [[:srv_created_at,'created-at'],
                          [:details,'details'],
                          [:external_id,'external-id'],
                          [:target_id,'id'],
                          [:is_active,'is-active'],
                          [:last_login,'last-login'],
                          [:locale_id,'locale-id'],
                          [:name,'name'],
                          [:notes,'notes'],
                          [:openid_url,'openid-url'],
                          [:organization_id,'organization-id'],
                          [:phone,'phone'],
                          [:restriction_id,'restriction-id'],
                          [:roles,'roles'],
                          [:time_zone,'time-zone'],
                          [:updated_at,'updated-at'],
                          [:uses_12_hour_clock,'uses-12-hour-clock'],
                          [:email,'email'],
                          [:is_verified,'is-verified'],
                          [:photo_url,'photo-url']]
      @params[:parent] = "user"
      @params[:key_field] = :target_id

#      fill data to source table
      Zendesk::User.destroy_all
      record = ::Zendesk::User.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/users.xml'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Zendesk::User.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/users.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        User.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        User.update_data(arr_obj)
        obj_1 = User.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        User.update_data(arr_obj)
        obj_2 = User.find_by_target_id("1")
#      compariation
        obj_1.name.should == "Harry Potter"
        obj_2.name.should == "Name changed"
#      check count of record, should unchange
      end.should change(User, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      User.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        User.update_data(arr_obj)
        obj_1 = User.find_by_target_id("2")
        obj_1.name.should == "This is a second user"
#      check count of record, should increase by 1
      end.should change(User, :count).by(1)
    end

    it "should get data from source table correctly" do
      User.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(User)
      obj_1 = User.find_by_target_id("2")
      obj_1.name.should == "This is a second user"
      end.should change(User, :count).by(2)
    end
  end
end

