require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Zendesk

describe "::BusinessDomain::Zendesk::TicketComment" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Zendesk::Util.load_fixture("ticket_1")
      @xml_2 = ::Zendesk::Util.load_fixture("ticket_2")
      @xml_1_changed = ::Zendesk::Util.load_fixture("ticket_1_changed")
      @params = {}
      @params[:mapper] = [[:arr_comment_create_at,'comments//comment']]
      @params[:be_array] = [:arr_comment_create_at,'created-at']
      @params[:parent] = "ticket"
      @params[:key_field] = :arr_comment_create_at
      @params[:change] = [:ticket_id,:target_id]
#      -------
      @params_cmt = {}
      @params_cmt[:mapper] =  [[:author_id	,'author-id'],
                            [:srv_created_at	,'created-at'],
                            [:is_public	,'is-public'],
                            [:type_ele	,'type'],
                            [:value	,'value'],
                            [:via_id	,'via-id']]
      @params_cmt[:parent] = 'ticket/comments//comment'
      @params_cmt[:key_field] = :author_id
      @params_cmt[:change] = [:token,:target_id]
#      -------
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
      Zendesk::Ticket.destroy_all
      Ticket.destroy_all
      Comment.destroy_all
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
      arr_obj.push Parser.parse(@xml_1,@params_cmt)
      arr_obj.push Parser.parse(@xml_2,@params_cmt)
      arr_obj[0][0][:token] = '1--testtpl'
      arr_obj[1][0][:token] = '2--testtpl'
      Comment.update_data(arr_obj)   
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params_tik)
      arr_obj.push Parser.parse(@xml_2,@params_tik)
      arr_obj[0][0][:nice_id] = '1--testtpl'
      arr_obj[1][0][:nice_id] = '2--testtpl'
      Ticket.update_data(arr_obj)
    end

    it "should unchange number of records when same ticket_field_id and ticket_id" do
#      reset table
        TicketComment.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        arr_obj[0][0][:ticket_id] = '1--testtpl'
        TicketComment.update_data(arr_obj)
        obj_1 = TicketComment.find(:last)
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        arr_obj[0][0][:ticket_id] = '1--testtpl'
        TicketComment.update_data(arr_obj)
        obj_2 = TicketComment.find(:last)
#      check association
        obj_1.comment.value.should == "faslfjkaslasflfl"
#      check count of record, should unchange
      end.should change(TicketComment, :count).by(0)
    end

    it "should insert data when new ticket_field_id and ticket_id" do
#      reset table
      TicketComment.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        arr_obj[0][0][:ticket_id] = '2--testtpl'
        TicketComment.update_data(arr_obj)  
        obj_1 = TicketComment.find(:last)
        obj_1.comment.value.should == "this is an comment"
#      check count of record, should increase by 1
      end.should change(TicketComment, :count).by(1)
    end

    it "should get data from source table correctly" do
      TicketComment.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(TicketComment)
      obj_1 = TicketComment.find(:last)
      obj_1.comment.value.should == "this is an comment"
      end.should change(TicketComment, :count).by(2)
    end
  end
end

