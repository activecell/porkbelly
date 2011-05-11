require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Macro" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("macro_1")
      @xml_2 = ::Zendesk::Util.load_fixture("macro_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("macro_1_changed")
      @params = {}


      @params[:mapper] = [[:target_id	,'id'],
                          [:title	,'title'],
                          [:availability_type	,'availability-type']]
      @params[:parent] = "macro"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::Macro.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/macros.xml'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Zendesk::Macro.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/macros.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        Macro.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Macro.update_data(arr_obj)
        obj_1 = Macro.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Macro.update_data(arr_obj)
        obj_2 = Macro.find_by_target_id("1")
#      compariation
        obj_1.title.should == "Customer not responding"
        obj_2.title.should == "Title changed"
#      check count of record, should unchange
      end.should change(Macro, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Macro.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Macro.update_data(arr_obj)
        obj_1 = Macro.find_by_target_id("2")
        obj_1.title.should == "Take it"
#      check count of record, should increase by 1
      end.should change(Macro, :count).by(1)
    end

    it "should get data from source table correctly" do
      Macro.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Macro)
      obj_1 = Macro.find_by_target_id("2")
      obj_1.title.should == "Take it"
      end.should change(Macro, :count).by(2)
    end
  end
end

