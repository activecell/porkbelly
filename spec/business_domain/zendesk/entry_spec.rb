require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Entry" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("entry_1")
      @xml_2 = ::Zendesk::Util.load_fixture("entry_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("entry_1_changed")
      @params = {}


      @params[:mapper] = [[:body,'body'],
                          [:srv_created_at,'created-at'],
                          [:current_tags,'current-tags'],
                          [:flag_type_id,'flag-type-id'],
                          [:forum_id,'forum-id'],
                          [:hits,'hits'],
                          [:target_id,'id'],
                          [:is_highlighted,'is-highlighted'],
                          [:is_locked,'is-locked'],
                          [:is_pinned,'is-pinned'],
                          [:is_public,'is-public'],
                          [:organization_id,'organization-id'],
                          [:position,'position'],
                          [:posts_count,'posts-count'],
                          [:submitter_id,'submitter-id'],
                          [:title,'title'],
                          [:srv_updated_at,'updated-at'],
                          [:votes_count,'votes-count']]
      @params[:parent] = "entry"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::Entry.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/entries.xml'
      record.format = 'xml'
      record.forum_id = 1
      record.update_attributes(record)

      record = ::Zendesk::Entry.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/entries.xml'
      record.format = 'xml'
      record.forum_id = 1
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        Entry.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Entry.update_data(arr_obj)
        obj_1 = Entry.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Entry.update_data(arr_obj)
        obj_2 = Entry.find_by_target_id("1")
#      compariation
        obj_1.body.should == "This is the body of the text"
        obj_2.body.should == "Body changed"
#      check count of record, should unchange
      end.should change(Entry, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Entry.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Entry.update_data(arr_obj)
        obj_1 = Entry.find_by_target_id("2")
        obj_1.body.should == "This is a second entry"
#      check count of record, should increase by 1
      end.should change(Entry, :count).by(1)
    end

    it "should get data from source table correctly" do
      Entry.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Entry)
      obj_1 = Entry.find_by_target_id("2")
      obj_1.body.should == "This is a second entry"
      end.should change(Entry, :count).by(2)
    end
  end
end

