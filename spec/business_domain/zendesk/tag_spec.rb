require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Tag" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("tag_1")
      @xml_2 = ::Zendesk::Util.load_fixture("tag_2")
      @params = {}
      @params[:mapper] = [[:account_id	,'account-id'],
                          [:target_id	,'id'],
                          [:score	,'score'],
                          [:tag_id	,'tag-id'],
                          [:tag_name	,'tag-name']]
      @params[:parent] = "tag-score"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::Tag.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/entries.xml'
      record.format = 'xml'
      record.update_attributes(record)

      record = ::Zendesk::Tag.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/entries.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end
    it "should insert data when new target_id" do
#      reset table
      Tag.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Tag.update_data(arr_obj)
        obj_1 = Tag.find_by_target_id("2")
        obj_1.tag_name.should == "setting"
#      check count of record, should increase by 1
      end.should change(Tag, :count).by(1)
    end

    it "should get data from source table correctly" do
      Tag.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Tag)
      obj_1 = Tag.find_by_target_id("1")
      obj_1.tag_name.should == "appear"
      end.should change(Tag, :count).by(2)
    end
  end
end

