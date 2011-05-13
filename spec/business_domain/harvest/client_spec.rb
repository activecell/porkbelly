require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::Client" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("client_1")
      @xml_2 = ::Harvest::Util.load_fixture("client_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("client_1_changed")
      @params = {}
      @params[:mapper] = [[:name	,'name'],
                          [:srv_created_at	,'created-at'],
                          [:details	,'details'],
                          [:srv_updated_at	,'updated-at'],
                          [:highrise_id	,'highrise-id'],
                          [:target_id	,'id'],
                          [:cache_version	,'cache-version'],
                          [:default_invoice_timeframe	,'default-invoice-timeframe'],
                          [:currency	,'currency'],
                          [:active	,'active'],
                          [:currency_symbol	,'currency-symbol']]
      @params[:parent] = "client"
      @params[:key_field] = :target_id

#      fill data to source table
      record = ::Harvest::Client.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Client.find_or_initialize_by_target_id("2")
      record.content = @xml_2
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      
    end

    it "should update data to table when same target_id" do
#      reset table
        Client.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Client.update_data(arr_obj)
        obj_1 = Client.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Client.update_data(arr_obj)
        obj_2 = Client.find_by_target_id("1")
#      compariation
        obj_1.name.should == "HNGHIEM"
        obj_2.name.should == "Changed"
#      check count of record, should unchange
      end.should change(Client, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Client.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Client.update_data(arr_obj)
        obj_1 = Client.find_by_target_id("2")
        obj_1.name.should == "This is a second client"
#      check count of record, should increase by 1
      end.should change(Client, :count).by(1)
    end

    it "should get data from source table correctly" do
      Client.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Client)
      obj_1 = Client.find_by_target_id("2")
      obj_1.name.should == "This is a second client"
      end.should change(Client, :count).by(2)
    end
  end
end

