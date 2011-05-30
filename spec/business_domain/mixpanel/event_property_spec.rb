require File.dirname(__FILE__) + "/spec_helper"
require 'digest/md5'

include  ::BusinessDomain::Mixpanel

describe "::BusinessDomain::Mixpanel::EventProperty" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Mixpanel::Util.load_fixture("event_property_1")
      @xml_2 = ::Mixpanel::Util.load_fixture("event_property_2")
      @xml_1_changed = ::Mixpanel::Util.load_fixture("event_property_1_changed")
      @token_1 = Digest::MD5.hexdigest('Test MixPanel API' + "+" + 'for test')
      @token_2 = Digest::MD5.hexdigest('Visist Home Page' + "+" + 'for test')
      @params = {}
      @params[:root] = "data/values"
      @params[:change] = [[:name,:target_id],[:event_token,:event_name],[:credential,:credential]]
      @params[:block] = lambda {|content|
      
            object = []
            data = JSON content
            roots = @params[:root].split('/')
            roots.each {|element| data = data[element]}
            
            data.each do |key, value| 
              
              data[key].each do |a|
                next if a[1] == 0
                element = {}
                element.update :value => key
                element.update :at_date => a[0]
                element.update :srv_count => a[1]
                object.push element
              end
            end
            object
          }
#      fill data to source table
      record = ::Mixpanel::EventProperty.find_or_initialize_by_target_id("test_num")
      record.content = @xml_1
      record.credential = 'for test'
      record.event_name = 'Test MixPanel API'
      record.target_id = "test_num"
      record.request_url = "www.google.com"
      record.update_attributes(record)
      record = ::Mixpanel::EventProperty.find_or_initialize_by_target_id("test_time")
      record.content = @xml_2
      record.credential = 'for test'
      record.event_name = 'Visist Home Page'
      record.target_id = 'test_time'
      record.request_url = "www.google.com"
      record.update_attributes(record)
      
    end

    it "should update data to table when same token,name,value and at_date" do
#      reset table
        EventProperty.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'test_num'
          element[:credential] = 'for test'
          element[:event_token] = 'Test MixPanel API'
        end
        EventProperty.update_data(arr_obj)
        obj_1 = EventProperty.find_by_event_token_and_name_and_at_date_and_value(@token_1,'test_num',"2011-04-27",'56')
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'test_num'
          element[:credential] = 'for test'
          element[:event_token] = 'Test MixPanel API'
        end
        EventProperty.update_data(arr_obj)
        obj_2 = EventProperty.find_by_event_token_and_name_and_at_date_and_value(@token_1,'test_num',"2011-04-27",'56')
#      compariation
        obj_1.srv_count.should == "1"
        obj_2.srv_count.should == "6"
#      check count of record, should unchange
      end.should change(EventProperty, :count).by(0)
    end

    it "should insert data when new target_id" do
#      reset table
      EventProperty.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'test_time'
          element[:credential] = 'for test'
          element[:event_token] = 'Visist Home Page'
        end
        EventProperty.update_data(arr_obj)
        obj_1 = EventProperty.find_by_event_token_and_name_and_at_date_and_value(@token_2,'test_time',"2011-05-15",'VN')
        obj_1.srv_count.should == "1"
#      check count of record, should increase by 1
      end.should change(EventProperty, :count).by(2)
    end

    it "should get data from source table correctly" do
      EventProperty.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(EventProperty, "SPEC")
        obj_1 = EventProperty.find_by_event_token_and_name_and_at_date_and_value(@token_2,'test_time',"2011-05-15",'VN')
        obj_1.srv_count.should == "1"
      end.should change(EventProperty, :count).by(7)
    end
  end
end

