require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Comment" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("ticket_1")
      @xml_2 = ::Zendesk::Util.load_fixture("ticket_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("ticket_1_changed")
      @params = {}
      @params[:mapper] =  [[:author_id	,'author-id'],
                            [:srv_created_at	,'created-at'],
                            [:is_public	,'is-public'],
                            [:type_ele	,'type'],
                            [:value	,'value'],
                            [:via_id	,'via-id']]
      @params[:parent] = 'ticket/comments//comment'
      @params[:key_field] = :author_id
      @params[:change] = [:token,:target_id]

#      fill data to source table
      record = ::Zendesk::Ticket.find_or_initialize_by_target_id("1--testtpl")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/tickets.xml'
      record.format = 'xml'
      record.subdomain = 'testtpl'
      record.target_id = '1--testtpl'
      record.update_attributes(record)
      record = ::Zendesk::Ticket.find_or_initialize_by_target_id("2--testtpl")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/tickets.xml'
      record.format = 'xml'
      record.subdomain = 'testtpl'
      record.target_id = '2--testtpl'
      record.update_attributes(record)
    end

    it "should update data to table when same token" do
#      reset table
        Comment.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Comment.update_data(arr_obj)
        obj_1 = Comment.find_by_token("2011-02-24T17:06:40+07:00+")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Comment.update_data(arr_obj)
        obj_2 = Comment.find_by_token("2011-02-24T17:06:40+07:00+")
#      compariation
        obj_1.value.should == "faslfjkaslasflfl"
        obj_2.value.should == "Value be changed"
#      check count of record, should unchange
      end.should change(Comment, :count).by(0)
    end

    it "should insert data when new token" do
#      reset table
      Comment.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Comment.update_data(arr_obj)
        obj_1 = Comment.find_by_token("2011-02-14T13:15:21+07:00+")
        obj_1.value.should == "this is an comment"
#      check count of record, should increase by 1
      end.should change(Comment, :count).by(1)
    end

    it "should get data from source table correctly" do
      Comment.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Comment)
      obj_1 = Comment.find_by_token("2011-02-14T13:15:21+07:00+2--testtpl")
      obj_1.value.should == "this is an comment"
      end.should change(Comment, :count).by(2)
    end
  end
end

