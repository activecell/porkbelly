require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::Payment" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("payment_1")
      @xml_2 = ::Harvest::Util.load_fixture("payment_2")
      @params = {}
      @params[:mapper] = [[:srv_created_at	,'created-at'],
                          [:pay_pal_transaction_id	,'pay-pal-transaction-id'],
                          [:notes	,'notes'],
                          [:recorded_by_email	,'recorded-by-email'],
                          [:srv_updated_at	,'updated-at'],
                          [:amount	,'amount'],
                          [:invoice_id	,'invoice-id'],
                          [:payment_gateway_id	,'payment-gateway-id'],
                          [:authorization	,'authorization'],
                          [:target_id	,'id'],
                          [:recorded_by	,'recorded-by'],
                          [:paid_at	,'paid-at']]
      @params[:parent] = "payment"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_in = ::Harvest::Util.load_fixture("invoice_1")
      @xml_2_in = ::Harvest::Util.load_fixture("invoice_2")      
#      reset tables
      Invoice.destroy_all
#      fill data to source table
      record = ::Harvest::InvoicePayment.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::InvoicePayment.find_or_initialize_by_target_id("2")
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
      Payment.destroy_all
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      Payment.update_data(arr_obj)
      obj_1 = Payment.find_by_target_id("1")
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Payment.update_data(arr_obj)
        obj_2 = Payment.find_by_target_id("2")
        
        obj_2.amount.should == "200.0"
#        check relationship
        obj_2.invoice.state.should == "draf"
#      check count of record, should increase by 1
      end.should change(Payment, :count).by(1)
    end

    it "should get data from source table correctly" do
      Payment.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Payment)
        obj_1 = Payment.find_by_target_id("2")
        obj_1.invoice.state.should == "draf"
        obj_1.amount.should == "200.0"
#         check relationship
        obj_1.invoice.state.should == "draf"
      end.should change(Payment, :count).by(2)
    end
  end
end

