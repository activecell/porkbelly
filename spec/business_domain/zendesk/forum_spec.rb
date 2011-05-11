require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Forum" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("forum_1")
      @xml_2 = ::Zendesk::Util.load_fixture("forum_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("forum_1_changed")
      @params = {}
      @params[:mapper] = [[:category_id,'category-id'],
                          [:description,'description'],
                          [:display_type_id,'display-type-id'],
                          [:entries_count,'entries-count'],
                          [:target_id,'id'],
                          [:is_locked,'is-locked'],
                          [:name,'name'],
                          [:organization_id,'organization-id'],
                          [:position,'position'],
                          [:translation_locale_id,'translation-locale-id'],
                          [:srv_updated_at,'updated-at'],
                          [:use_for_suggestions,'use-for-suggestions'],
                          [:visibility_restriction_id,'visibility-restriction-id'],
                          [:is_public ,'is-public ']]
      @params[:parent] = "forum"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::Forum.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/forums.xml'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Zendesk::Forum.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/forums.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        Forum.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Forum.update_data(arr_obj)
        obj_1 = Forum.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Forum.update_data(arr_obj)
        obj_2 = Forum.find_by_target_id("1")
#      compariation
        obj_1.description.should == "New features, fixes, and other important announcements."
        obj_2.description.should == "Description changed"
#      check count of record, should unchange
      end.should change(Forum, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Forum.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Forum.update_data(arr_obj)
        obj_1 = Forum.find_by_target_id("2")
        obj_1.description.should == "Supporting"
#      check count of record, should increase by 1
      end.should change(Forum, :count).by(1)
    end

    it "should get data from source table correctly" do
      Forum.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Forum)
      obj_1 = Forum.find_by_target_id("2")
      obj_1.description.should == "Supporting"
      end.should change(Forum, :count).by(2)
    end
  end
end

