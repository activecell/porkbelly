require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Post" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("organization_1")
      @xml_2 = ::Zendesk::Util.load_fixture("organization_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("organization_1_changed")
      @params = {}
      @params[:mapper] = [[:account_id,'account-id'],
                          [:body,'body'],
                          [:created_at,'created-at'],
                          [:entry_id,'entry-id'],
                          [:forum_id,'forum-id'],
                          [:target_id,'id'],
                          [:is_informative,'is-informative'],
                          [:updated_at,'updated-at'],
                          [:user_id,'user-id']]
      @params[:parent] = "organization"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::Post.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/post.xml'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Zendesk::Post.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/post.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        Post.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Post.update_data(arr_obj)
        obj_1 = Post.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Post.update_data(arr_obj)
        obj_2 = Post.find_by_target_id("1")
#      compariation
        obj_1.name.should == "utwkidvn"
        obj_2.name.should == "Name be changed"
#      check count of record, should unchange
      end.should change(Post, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Post.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Post.update_data(arr_obj)
        obj_1 = Post.find_by_target_id("2")
        obj_1.name.should == "this is an organization"
#      check count of record, should increase by 1
      end.should change(Post, :count).by(1)
    end

    it "should get data from source table correctly" do
      Post.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Post)
      obj_1 = Post.find_by_target_id("2")
      obj_1.name.should == "this is an organization"
      end.should change(Post, :count).by(2)
    end
  end
end

