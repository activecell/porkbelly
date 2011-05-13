require File.dirname(__FILE__) + "/spec_helper"
include  ::BusinessDomain::Harvest

describe "::BusinessDomain::Harvest::Contact" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Harvest::Util.load_fixture("contact_1")
      @xml_2 = ::Harvest::Util.load_fixture("contact_2")
      @xml_1_changed = ::Harvest::Util.load_fixture("contact_1_changed")
      @params = {}
      @params[:mapper] = [[:target_id ,'id '],
                          [:client_id ,'client-id '],
                          [:email ,'email '],
                          [:first_name ,'first-name '],
                          [:last_name ,'last-name '],
                          [:phone_office ,'phone-office '],
                          [:phone_mobile ,'phone-mobile '],
                          [:fax ,'fax '],
                          [:srv_updated_at ,'updated-at '],
                          [:srv_created_at ,'created-at ']]
      @params[:parent] = "contact"
      @params[:key_field] = :target_id
#      ----------------------
      @xml_1_cl = ::Harvest::Util.load_fixture("client_1")
      @xml_2_cl = ::Harvest::Util.load_fixture("client_2")
#      reset tables
      Client.destroy_all
#      fill data to source table
      record = ::Harvest::Contact.find_or_initialize_by_target_id("1")
      record.content = @xml_1
      record.credential = 'for test'
      record.request_url = 'for test'
      record.format = 'xml'
      record.update_attributes(record)
      record = ::Harvest::Contact.find_or_initialize_by_target_id("2")
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
        Contact.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params)
        Contact.update_data(arr_obj)
        obj_1 = Contact.find_by_target_id("1")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params)
        Contact.update_data(arr_obj)
        obj_2 = Contact.find_by_target_id("1")
#        compariation
        obj_1.email.should == "Jane@Doe.com"
        obj_2.email.should == "change@email.com"
#        check relationship
        obj_1.client.srv_created_at.should == "2011-02-21T04:51:52Z"
#        check count of record, should unchange
      end.should change(Contact, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      Contact.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params)
        Contact.update_data(arr_obj)
        obj_1 = Contact.find_by_target_id("2")
        obj_1.email.should == "Second@email.com"
#        check relationship
        obj_1.client.name.should == "This is a second client"        
#      check count of record, should increase by 1
      end.should change(Contact, :count).by(1)
    end

    it "should get data from source table correctly" do
      Contact.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Contact)
        obj_1 = Contact.find_by_target_id("2")
        obj_1.email.should == "Second@email.com"
#         check relationship
        obj_1.client.name.should == "This is a second client" 
      end.should change(Contact, :count).by(2)
    end
  end
end

