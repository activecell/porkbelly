require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::Ticket" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("ticket_1")
      @xml_2 = ::Zendesk::Util.load_fixture("ticket_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("ticket_1_changed")
      @params = {}
      @params[:mapper] = [[:assigned_at,'assigned-at'],
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
      @params[:parent] = "ticket"
      @params[:key_field] = :nice_id
      @params[:change] = [:subdomain,:subdomain]
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

    it "should update data to table when same nice_id" do
#      reset table
        Ticket.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Ticket.update_data(arr_obj)
        obj_1 = Ticket.find_by_nice_id("1")
        obj_1.description.should == "faslfjkaslasflfl"
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Ticket.update_data(arr_obj)
        obj_2 = Ticket.find_by_nice_id("1")
#      compariation
        obj_2.description.should == "description changed"
#      check count of record, should unchange
      end.should change(Ticket, :count).by(0)
    end

    it "should insert data when new nice_id" do
#      reset table
      Ticket.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Ticket.update_data(arr_obj)
        obj_1 = Ticket.find_by_nice_id("2")
        obj_1.assignee_id.should == "27323924"
#      check count of record, should increase by 1
      end.should change(Ticket, :count).by(1)
    end

    it "should get data from source table correctly" do
      Ticket.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Ticket)
      obj_1 = Ticket.find_by_nice_id("2--testtpl")
      obj_1.assignee_id.should == "27323924"
      end.should change(Ticket, :count).by(2)
    end
  end
end

