require File.dirname(__FILE__) + "/spec_helper"
require 'digest/md5'

include  ::BusinessDomain::Mixpanel

describe "::BusinessDomain::Mixpanel::Event" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Mixpanel::Util.load_fixture("event_1")
      @xml_2 = ::Mixpanel::Util.load_fixture("event_2")
      @xml_1_changed = ::Mixpanel::Util.load_fixture("event_1_changed")
      @token_1 = Digest::MD5.hexdigest('Test MixPanel API' + "+" + 'for test')
      @token_2 = Digest::MD5.hexdigest('Visist Home Page' + "+" + 'for test')
      @params = {}
      @params[:root] = "data/values"
      @params[:key] = :at_date
      @params[:value] = :srv_count
      @params[:change] = [[:name,:target_id],[:token,:credential]]
      @params[:block] = lambda {|content|
            object = []
            data = JSON content
            roots = @params[:root].split('/')
            roots.each {|element| data = data[element]}
            
            data.each do |key, value| 
              data[key].each do |a|
                next if a[1] == 0
                element = {}
                element[@params[:key]] = a[0]
                element[@params[:value]] = a[1]
                object.push element
              end
            end
            object
          }
#      fill data to source table
      record = ::Mixpanel::Event.find_or_initialize_by_target_id("Test MixPanel API")
      record.content = @xml_1
      record.credential = 'for test'
      record.target_id = 'Test MixPanel API'
      record.request_url = "www.google.com"
      record.update_attributes(record)
      record = ::Mixpanel::Event.find_or_initialize_by_target_id("Visist Home Page")
      record.content = @xml_2
      record.credential = 'for test'
      record.target_id = 'Visist Home Page'
      record.request_url = "www.google.com"
      record.update_attributes(record)
      
    end

    it "should update data to table when same token and at_date" do
#      reset table
        Event.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'Test MixPanel API'
          element[:token] = 'for test'
        end
        Event.update_data(arr_obj)
        obj_1 = Event.find_by_token_and_at_date(@token_1,"2011-05-15")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'Test MixPanel API'
          element[:token] = 'for test'
        end
        Event.update_data(arr_obj)
        obj_2 = Event.find_by_token_and_at_date(@token_1,"2011-05-15")
#      compariation
        obj_1.srv_count.should == "1"
        obj_2.srv_count.should == "5"
#      check count of record, should unchange
      end.should change(Event, :count).by(0)
    end

    it "should insert data when new token and at_date" do
#      reset table
      Event.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'Visist Home Page'
          element[:token] = 'for test'
        end
        Event.update_data(arr_obj)
        obj_1 = Event.find_by_token_and_at_date(@token_2,"2011-04-27")
        obj_1.srv_count.should == "1"
#      check count of record, should increase by 1
      end.should change(Event, :count).by(4)
    end

    it "should get data from source table correctly" do
      Event.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Event, "SPEC")
        obj_1 = Event.find_by_token_and_at_date(@token_2,"2011-04-27")
        obj_1.srv_count.should == "1"
      end.should change(Event, :count).by(7)
    end
  end
end

