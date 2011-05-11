require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::GroupUser" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("user_1")
      @xml_2 = ::Zendesk::Util.load_fixture("user_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("user_1_changed")
      @params = {}
      @params[:mapper] = [[:arr_group_id,'groups//group']]
      @params[:be_array] = [:arr_group_id,'id']
      @params[:parent] = "user"
      @params[:key_field] = :arr_group_id
      @params[:change] = [:user_id,:target_id]
#      ------
      @xml_1_grp = ::Zendesk::Util.load_fixture("group_1")
      @xml_2_grp = ::Zendesk::Util.load_fixture("group_2")
      @params_grp = {}
      @params_grp[:mapper] = [[:srv_created_at,'created-at'],
                          [:target_id,'id'],
                          [:is_active,'is-active'],
                          [:name,'name'],
                          [:srv_updated_at,'updated-at']]
      @params_grp[:parent] = "group"
      @params_grp[:key_field] = :target_id
#      --------
      @params_usr = {}
      @params_usr[:mapper] = [[:srv_created_at,'created-at'],
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
      @params_usr[:parent] = "user"
      @params_usr[:key_field] = :target_id
#      reset tables
      User.destroy_all
      Group.destroy_all
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
#      --------
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1_grp,@params_grp)
      arr_obj.push Parser.parse(@xml_2_grp,@params_grp)
      Group.update_data(arr_obj)   
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params_usr)
      arr_obj.push Parser.parse(@xml_2,@params_usr)
      User.update_data(arr_obj)
    end

    it "should unchange number of records when same user_id and group_id" do
#      reset table
        GroupUser.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        arr_obj[0][0][:user_id] = '1'
        GroupUser.update_data(arr_obj)
        obj_1 = GroupUser.find(:last)
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        arr_obj[0][0][:user_id] = '1'
        GroupUser.update_data(arr_obj)
        obj_2 = GroupUser.find(:last)
#      check association
        obj_1.group.name.should == "Support"
        obj_1.user.name.should == "Harry Potter"
#      check count of record, should unchange
      end.should change(GroupUser, :count).by(0)
    end

    it "should insert data when new user_id and group_id" do
#      reset table
      GroupUser.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        arr_obj[0][0][:user_id] = '2'
        GroupUser.update_data(arr_obj)
        obj_1 = GroupUser.find(:last)
        obj_1.group.name.should == "Developers"
        obj_1.user.name.should == "This is a second user"
#      check count of record, should increase by 1
      end.should change(GroupUser, :count).by(1)
    end

    it "should get data from source table correctly" do
      GroupUser.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(GroupUser)
      obj_1 = GroupUser.find(:last)
      obj_1.group.name.should == "Developers"
      obj_1.user.name.should == "This is a second user"
      end.should change(GroupUser, :count).by(2)
    end
  end
end

