require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::InvoiceMessage" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("invoice_message_1")
      @xml_2 = ::Harvest::Util.load_fixture("invoice_message_2")
      @params = {}
      @params[:mapper] = [[:sent_by_email	,'sent-by-email	'],
                          [:srv_created_at	,'created-at	'],
                          [:include_pay_pal_link	,'include-pay-pal-link	'],
                          [:thank_you	,'thank-you	'],
                          [:body	,'body	'],
                          [:send_me_a_copy	,'send-me-a-copy	'],
                          [:srv_updated_at	,'updated-at	'],
                          [:invoice_id	,'invoice-id	'],
                          [:target_id	,'id	'],
                          [:subject	,'subject	'],
                          [:sent_by	,'sent-by	'],
                          [:full_recipient_list	,'full-recipient-list	']]
      @params[:parent] = "invoice-message"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_in = ::Harvest::Util.load_fixture("invoice_1")
      @xml_2_in = ::Harvest::Util.load_fixture("invoice_2")      
#      reset tables
      Invoice.destroy_all
#      fill data to source table
      record = ::Harvest::InvoiceMessage.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::InvoiceMessage.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      ------------------
      record = ::Harvest::Invoice.find_or_initialize_by_target_id("1")
      record.content = @xml_1_in
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Invoice.find_or_initialize_by_target_id("2")
      record.content = @xml_2_in
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      --------
      Parser.parse_all Invoice 
    end

    it "should insert data when new target_id" do
#      reset table
      InvoiceMessage.destroy_all
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      InvoiceMessage.update_data(arr_obj)
      obj_1 = InvoiceMessage.find_by_target_id("1")
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        InvoiceMessage.update_data(arr_obj)
        obj_2 = InvoiceMessage.find_by_target_id("2")
        
        obj_2.body.should == "Second Invoice Message"
#        check relationship
        obj_2.invoice.state.should == "draf"
#      check count of record, should increase by 1
      end.should change(InvoiceMessage, :count).by(1)
    end

    it "should get data from source table correctly" do
      InvoiceMessage.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(InvoiceMessage)
        obj_1 = InvoiceMessage.find_by_target_id("2")
        obj_1.invoice.state.should == "draf"
        obj_1.body.should == "Second Invoice Message"
#         check relationship
        obj_1.invoice.state.should == "draf"
      end.should change(InvoiceMessage, :count).by(2)
    end
  end
end

