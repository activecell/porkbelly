require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::InvoiceCategory" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("invoice_category_1")
      @xml_2 = ::Harvest::Util.load_fixture("invoice_category_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("invoice_category_1_changed")
      @params = {}
      @params[:mapper] = [[:name	,'name'],
                          [:srv_created_at	,'created-at'],
                          [:srv_updated_at	,'updated-at'],
                          [:use_as_expense	,'use-as-expense'],
                          [:use_as_service	,'use-as-service'],
                          [:target_id	,'id']]
      @params[:parent] = "invoice-item-category"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Harvest::InvoiceCategory.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::InvoiceCategory.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      
    end

    it "should update data to table when same target_id" do
#      reset table
        InvoiceCategory.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        InvoiceCategory.update_data(arr_obj)
        obj_1 = InvoiceCategory.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        InvoiceCategory.update_data(arr_obj)
        obj_2 = InvoiceCategory.find_by_target_id("1")
#      compariation
        obj_1.name.should == "Service"
        obj_2.name.should == "Changed"
#      check count of record, should unchange
      end.should change(InvoiceCategory, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      InvoiceCategory.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        InvoiceCategory.update_data(arr_obj)
        obj_1 = InvoiceCategory.find_by_target_id("2")
        obj_1.name.should == "Product"
#      check count of record, should increase by 1
      end.should change(InvoiceCategory, :count).by(1)
    end

    it "should get data from source table correctly" do
      InvoiceCategory.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(InvoiceCategory)
      obj_1 = InvoiceCategory.find_by_target_id("2")
      obj_1.name.should == "Product"
      end.should change(InvoiceCategory, :count).by(2)
    end
  end
end

