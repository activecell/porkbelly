require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::TicketFieldEntry" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("ticket_1")
      @xml_2 = ::Zendesk::Util.load_fixture("ticket_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("ticket_1_changed")
      @params = {}
      @params[:mapper] = [[:ticket_id,'id'],[:arr_ticket_field_id,'ticket-field-entries//ticket-field-entry'],[:value,'ticket-field-entries//ticket-field-entry']]
      @params[:be_array] = [[:arr_ticket_field_id,'ticket-field-id'],[:value,'value']]
      @params[:parent] = "ticket"
      @params[:key_field] = :arr_ticket_field_id
      @params[:change] = [:ticket_id,:target_id]
#      ---------
      @params_tif = {}
      @params_tif[:mapper] = [[:account_id,'account-id'],
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
      @params_tif[:parent] = "record"
      @params_tif[:key_field] = :target_id
#      -------
      @xml_1_tif = ::Zendesk::Util.load_fixture("ticket_field_1")
      @xml_2_tif = ::Zendesk::Util.load_fixture("ticket_field_2")
      @params_tik = {}
      @params_tik[:mapper] = [[:assigned_at,'assigned-at'],
                          [:assignee_id,'assignee-id'],
                          [:base_score,'base-score'],
                          [:srv_created_at,'created-at'],
                          [:current_collaborators,'current-collaborators'],
                          [:current_tags,'current-tags'],
                          [:description,'description'],
                          [:due_date,'due-date'],
                          [:entry_id,'entry-id'],
                          [:external_id,'external-id'],
                          [:group_id,'group-id'],
                          [:initially_assigned_at,'initially-assigned-at'],
                          [:latest_recipients,'latest-recipients'],
                          [:nice_id,'nice-id'],
                          [:organization_id,'organization-id'],
                          [:original_recipient_address,'original-recipient-address'],
                          [:priority_id,'priority-id'],
                          [:recipient,'recipient'],
                          [:requester_id,'requester-id'],
                          [:resolution_time,'resolution-time'],
                          [:solved_at,'solved-at'],
                          [:status_id,'status-id'],
                          [:status_updated_at,'status-updated-at'],
                          [:subject,'subject'],
                          [:submitter_id,'submitter-id'],
                          [:ticket_type_id,'ticket-type-id'],
                          [:srv_updated_at,'updated-at'],
                          [:updated_by_type_id,'updated-by-type-id'],
                          [:via_id,'via-id'],
                          [:score,'score'],
                          [:problem_id,'problem-id'],
                          [:linkings,'linkings'],
                          [:channel,'channel']]
      @params_tik[:parent] = "ticket"
      @params_tik[:key_field] = :nice_id
      @params_tik[:change] = [:subdomain,:subdomain]
#      reset tables
      Ticket.destroy_all
      TicketField.destroy_all
      Zendesk::Ticket.destroy_all
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
#      --------
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1_tif,@params_tif)
      arr_obj.push Parser.parse(@xml_2_tif,@params_tif)
      TicketField.update_data(arr_obj)   
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params_tik)
      arr_obj.push Parser.parse(@xml_2,@params_tik)
      arr_obj[0][0][:nice_id] = '1--testtpl'
      arr_obj[1][0][:nice_id] = '2--testtpl'
      Ticket.update_data(arr_obj)
    end

    it "should update data to table when same ticket_field_id and ticket_id" do
#      reset table
        TicketFieldEntry.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        arr_obj[0][0][:ticket_id] = '1--testtpl'
        TicketFieldEntry.update_data(arr_obj)
        obj_1 = TicketFieldEntry.find(:last)
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        arr_obj[0][0][:ticket_id] = '1--testtpl'
        TicketFieldEntry.update_data(arr_obj)
        obj_2 = TicketFieldEntry.find(:last)
#      compariation
        obj_1.value.should == '1'
        obj_2.value.should == '2'
#      check association
        obj_1.ticket_field.target_id.should == "1"
        obj_2.ticket_field.target_id.should == "1"
#      check count of record, should unchange
      end.should change(TicketFieldEntry, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      TicketFieldEntry.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        arr_obj[0][0][:ticket_id] = '2--testtpl'
        TicketFieldEntry.update_data(arr_obj)
        obj_1 = TicketFieldEntry.find(:last)
        obj_1.value.should == 'abc'
        obj_1.ticket_field.target_id.should == "2"
#      check count of record, should increase by 1
      end.should change(TicketFieldEntry, :count).by(1)
    end

    it "should get data from source table correctly" do
      TicketFieldEntry.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(TicketFieldEntry)
        obj_1 = TicketFieldEntry.find(:last)
        obj_1.value.should == 'abc'
        obj_1.ticket_field.target_id.should == "2"
      end.should change(TicketFieldEntry, :count).by(2)
    end
  end
end

