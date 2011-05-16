require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::Invoice" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("invoice_1")
      @xml_2 = ::Harvest::Util.load_fixture("invoice_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("invoice_1_changed")
      @params = {}
      @params[:mapper] = [[:number	,'number'],
                          [:period_end	,'period-end'],
                          [:tax	,'tax'],
                          [:srv_created_at	,'created-at'],
                          [:discount	,'discount'],
                          [:due_at_human_format	,'due-at-human-format'],
                          [:notes	,'notes'],
                          [:srv_updated_at	,'updated-at'],
                          [:amount	,'amount'],
                          [:client_key	,'client-key'],
                          [:discount_amount	,'discount-amount'],
                          [:period_start	,'period-start'],
                          [:recurring_invoice_id	,'recurring-invoice-id'],
                          [:due_amount	,'due-amount'],
                          [:target_id	,'id'],
                          [:subject	,'subject'],
                          [:tax_amount	,'tax-amount'],
                          [:client_id	,'client-id'],
                          [:purchase_order	,'purchase-order'],
                          [:tax2_amount	,'tax2-amount'],
                          [:currency	,'currency'],
                          [:retainer_id	,'retainer-id'],
                          [:estimate_id	,'estimate-id'],
                          [:issued_at	,'issued-at'],
                          [:tax2	,'tax2'],
                          [:due_at	,'due-at'],
                          [:state	,'state']]
      @params[:parent] = "invoice"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_cl = ::Harvest::Util.load_fixture("client_1")
      @xml_2_cl = ::Harvest::Util.load_fixture("client_2")      
#      reset tables
      Client.destroy_all
#      fill data to source table
      record = ::Harvest::Invoice.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Invoice.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      ------------------
      record = ::Harvest::Client.find_or_initialize_by_target_id("1")
      record.content = @xml_1_cl
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Client.find_or_initialize_by_target_id("2")
      record.content = @xml_2_cl
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
#      --------
      Parser.parse_all Client 
    end

    it "should update data to table when same target_id" do
#      reset table
      Invoice.destroy_all
      arr_obj = []
      arr_obj.push Parser.parse(@xml_1,@params)
      Invoice.update_data(arr_obj)
      obj_1 = Invoice.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Invoice.update_data(arr_obj)
        obj_2 = Invoice.find_by_target_id("1")
#        compariation
        obj_1.state.should == "sent"
        obj_2.state.should == "paid"
#        check relationship
        obj_1.client.name.should == "HNGHIEM"
#        check count of record, should unchange
      end.should change(Invoice, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Invoice.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Invoice.update_data(arr_obj)
        obj_1 = Invoice.find_by_target_id("2")
        obj_1.state.should == "draf"
#        check relationship
        obj_1.client.name.should == "This is a second client"
#      check count of record, should increase by 1
      end.should change(Invoice, :count).by(1)
    end

    it "should get data from source table correctly" do
      Invoice.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Invoice)
        obj_1 = Invoice.find_by_target_id("2")
        obj_1.state.should == "draf"
#         check relationship
        obj_1.client.name.should == "This is a second client"
      end.should change(Invoice, :count).by(2)
    end
  end
end

