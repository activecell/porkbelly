require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::TicketField" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("ticket_field_1")
      @xml_2 = ::Zendesk::Util.load_fixture("ticket_field_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("ticket_field_1_changed")
      @params = {}
      @params[:mapper] = [[:account_id,'account-id'],
                          [:srv_created_at,'created-at'],
                          [:title,'title'],
                          [:target_id,'id'],
                          [:is_active,'is-active'],
                          [:is_collapsed_for_agents,'is-collapsed-for-agents'],
                          [:is_editable_in_portal,'is-editable-in-portal'],
                          [:is_required,'is-required'],
                          [:is_required_in_portal,'is-required-in-portal'],
                          [:is_visible_in_portal,'is-visible-in-portal'],
                          [:position,'position'],
                          [:regexp_for_validation,'regexp-for-validation'],
                          [:sub_type_id,'sub-type-id'],
                          [:tag,'tag'],
                          [:title,'title'],
                          [:title_in_portal,'title-in-portal'],
                          [:type_ele,'type'],
                          [:srv_updated_at,'updated-at']]
      @params[:parent] = "record"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Zendesk::TicketField.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/ticket_fields.xml'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Zendesk::TicketField.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = '{:subdomain=>"tpltest", :username=>"utwkidvn@gmail.com"}'
      record.request_url = 'http://tpltest.zendesk.com/ticket_fields.xml'
      record.format = 'xml'
      record.update_attributes(record)
    end

    it "should update data to table when same target_id" do
#      reset table
        TicketField.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        TicketField.update_data(arr_obj)
        obj_1 = TicketField.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        TicketField.update_data(arr_obj)
        obj_2 = TicketField.find_by_target_id("1")
#      compariation
        obj_1.title.should == "Subject"
        obj_2.title.should == "Title changed"
#      check count of record, should unchange
      end.should change(TicketField, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      TicketField.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        TicketField.update_data(arr_obj)
        obj_1 = TicketField.find_by_target_id("2")
        obj_1.title.should == "This is a second record"
#      check count of record, should increase by 1
      end.should change(TicketField, :count).by(1)
    end

    it "should get data from source table correctly" do
      TicketField.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(TicketField)
      obj_1 = TicketField.find_by_target_id("2")
      obj_1.title.should == "This is a second record"
      end.should change(TicketField, :count).by(2)
    end
  end
end

