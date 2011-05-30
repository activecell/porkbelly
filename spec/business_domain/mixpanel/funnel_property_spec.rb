require File.dirname(__FILE__) + "/spec_helper"
require 'digest/md5'

include  ::BusinessDomain::Mixpanel

describe "::BusinessDomain::Mixpanel::FunnelProperty" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Mixpanel::Util.load_fixture("funnel_property_1")
      @xml_2 = ::Mixpanel::Util.load_fixture("funnel_property_2")
      @xml_1_f = ::Mixpanel::Util.load_fixture("funnel_1")
      @xml_2_f = ::Mixpanel::Util.load_fixture("funnel_2")
      @xml_1_changed = ::Mixpanel::Util.load_fixture("funnel_property_1_changed")
      @token_1 = Digest::MD5.hexdigest('Test Mixpanel API' + "+" + 'for test')
      @token_2 = Digest::MD5.hexdigest('Signup' + "+" + 'for test')
      @params = {}
      @params[:change] = [[:name,:target_id],[:funnel_name,:funnel_name],[:token,:credential]]
      @params[:block] = lambda {|content|
            object = []
            data = JSON content
            data.keys.each do |a|
              element = {}
              element.update :date => a 
              element.update :steps => data[a]["meta"]["steps"]
              element.update :values => data[a]["meta"]["values"].to_s
              object.push element
            end
            object
          }
      FunnelProperty.destroy_all
#      fill data to source table
      record = ::Mixpanel::FunnelProperty.find_or_initialize_by_target_id("mp_country_code")
      record.content = @xml_1
      record.credential = 'for test'
      record.target_id = 'mp_country_code'
      record.request_url = "www.google.com"
      record.funnel_name = "Test Mixpanel API"
      record.update_attributes(record)
      record = ::Mixpanel::FunnelProperty.find_or_initialize_by_target_id("gender")
      record.content = @xml_2
      record.credential = 'for test'
      record.target_id = 'gender'
      record.request_url = "www.google.com"
      record.funnel_name = "Signup"
      record.update_attributes(record)
      
      ::Mixpanel::Funnel.destroy_all
#      fill data to source table
      record = ::Mixpanel::Funnel.find_or_initialize_by_target_id("Test Mixpanel API")
      record.content = @xml_1_f
      record.credential = 'for test'
      record.target_id = 'Test Mixpanel API'
      record.request_url = "www.google.com"
      record.update_attributes(record)
      record = ::Mixpanel::Funnel.find_or_initialize_by_target_id("Signup")
      record.content = @xml_2_f
      record.credential = 'for test'
      record.target_id = 'Signup'
      record.request_url = "www.google.com"
      record.update_attributes(record)
      
      Parser.parse_all(Funnel, "SPEC")
    end

    it "should update data to table when same date,name and funnel_id" do
#      reset table
        FunnelProperty.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'mp_country_code'
          element[:token] = 'for test'
          element[:funnel_name] = 'Test Mixpanel API'
        end
        FunnelProperty.update_data(arr_obj)
        
        funnel = Funnel.find_by_token_and_at_date(@token_1,"2011-05-16")
        obj_1 = FunnelProperty.find_by_date_and_name_and_funnel_id("2011-05-16","mp_country_code",funnel[:id].to_s)
        
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'mp_country_code'
          element[:token] = 'for test'
          element[:funnel_name] = 'Test Mixpanel API'
        end
        FunnelProperty.update_data(arr_obj)
        funnel = Funnel.find_by_token_and_at_date(@token_1,"2011-05-16")
        obj_2 = FunnelProperty.find_by_date_and_name_and_funnel_id("2011-05-16","mp_country_code",funnel[:id].to_s)
#      compariation
        obj_1.steps.should == "1"
        obj_2.steps.should == "2"
#      check count of record, should unchange
      end.should change(FunnelProperty, :count).by(0)
    end

    it "should insert data when new date,name and funnel_id" do
#      reset table
      FunnelProperty.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'gender'
          element[:token] = 'for test'
          element[:funnel_name] = 'Signup'
        end
        FunnelProperty.update_data(arr_obj)
        funnel = Funnel.find_by_token_and_at_date(@token_2,"2011-05-16")
        obj_1 = FunnelProperty.find_by_date_and_name_and_funnel_id("2011-05-16","gender",funnel[:id].to_s)
        obj_1.steps.should == "2"
#      check count of record, should increase by 1
      end.should change(FunnelProperty, :count).by(2)
    end

    it "should get data from source table correctly" do
      FunnelProperty.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(FunnelProperty, "SPEC")
        funnel = Funnel.find_by_token_and_at_date(@token_2,"2011-05-16")
        obj_1 = FunnelProperty.find_by_date_and_funnel_id("2011-05-16",funnel[:id].to_s)
        obj_1.steps.should == "2"
      end.should change(FunnelProperty, :count).by(6)
    end
  end
end

