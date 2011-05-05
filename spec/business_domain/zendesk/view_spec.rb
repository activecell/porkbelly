require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::View" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("view_1")
      @xml_2 = ::Zendesk::Util.load_fixture("view_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("view_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id,'id'],
                          [:is_active,'is-active'],
                          [:owner_id,'owner-id'],
                          [:owner_type,'owner-type'],
                          [:per_page,'per-page'],
                          [:position,'position'],
                          [:title,'title']]
      @params[:parent] = "view"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::View.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/views.xml'
      record.format = 'xml'
      record.per_page = 15
      record.update_attributes(record)
      record = ::Zendesk::View.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/views.xml'
      record.format = 'xml'
      record.per_page = 15
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        View.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        View.update_data(arr_obj)
        obj_1 = View.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        View.update_data(arr_obj)
        obj_2 = View.find_by_target_id("1")
#      compariation
        obj_1.title.should == "New tickets in your groups"
        obj_2.title.should == "Title changed"
#      check count of record, should unchange
      end.should change(View, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      View.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        View.update_data(arr_obj)
        obj_1 = View.find_by_target_id("2")
        obj_1.title.should == "Recently solved tickets"
#      check count of record, should increase by 1
      end.should change(View, :count).by(1)
    end

    it "should get data from source table correctly" do
      View.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(View)
      obj_1 = View.find_by_target_id("2")
      obj_1.title.should == "Recently solved tickets"
      end.should change(View, :count).by(2)
    end
  end
end

