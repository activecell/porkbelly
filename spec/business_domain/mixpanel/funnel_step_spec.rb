require File.dirname(__FILE__) + "/spec_helper"
require 'digest/md5'

include  ::BusinessDomain::Mixpanel

describe "::BusinessDomain::Mixpanel::FunnelStep" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::Mixpanel::Util.load_fixture("funnel_1")
      @xml_2 = ::Mixpanel::Util.load_fixture("funnel_2")
      @xml_1_changed = ::Mixpanel::Util.load_fixture("funnel_1_changed")
      @token_1 = Digest::MD5.hexdigest('View my blog' + "+" + 'for test')
      @token_2 = Digest::MD5.hexdigest('Test Mixpanel API' + "+" + 'for test')
      @params = {}
      @params[:change] = [[:name,:target_id],[:token,:credential]]
      @params[:block] = lambda {|content|
            object = []
            data = JSON content
            # remove root
            data = data[data.keys[0]]["data"]
            data.each do |key, value| 
              data[key]["steps"].each do |a| 
                element = {}
                element.update :at_date => key
                element.update :srv_count => a["count"].to_s
                element.update :goal => a["goal"].to_s
                element.update :overall_conv_ratio => a["overall_conv_ratio"].to_s
                element.update :step_conv_ratio => a["step_conv_ratio"].to_s
                object.push element
              end
            end
            object
          }
#      fill data to source table
      record = ::Mixpanel::Funnel.find_or_initialize_by_target_id("Test MixPanel API")
      record.content = @xml_1
      record.credential = 'for test'
      record.target_id = 'View my blog'
      record.request_url = "www.google.com"
      record.update_attributes(record)
      record = ::Mixpanel::Funnel.find_or_initialize_by_target_id("Visist Home Page")
      record.content = @xml_2
      record.credential = 'for test'
      record.target_id = 'Test Mixpanel API'
      record.request_url = "www.google.com"
      record.update_attributes(record)
      
      Parser.parse_all(Funnel, "SPEC")
    end

    it "should update data to table when same token and at_date" do
#      reset table
        FunnelStep.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'View my blog'
          element[:token] = 'for test'
        end
        FunnelStep.update_data(arr_obj)
        funnel = Funnel.find_by_token_and_at_date(@token_1,"2011-05-16")
        obj_1 = FunnelStep.find_by_goal_and_funnel_id("Test MixPanel API",funnel[:id].to_s)
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'View my blog'
          element[:token] = 'for test'
        end
        FunnelStep.update_data(arr_obj)
        funnel = Funnel.find_by_token_and_at_date(@token_1,"2011-05-16")
        obj_2 = FunnelStep.find_by_goal_and_funnel_id("Test MixPanel API",funnel[:id].to_s)
#      compariation
        obj_1.overall_conv_ratio.should == "1.0"
        obj_2.overall_conv_ratio.should == "2.0"
#      check count of record, should unchange
      end.should change(FunnelStep, :count).by(0)
    end

    it "should insert data when new token and at_date" do
#      reset table
      FunnelStep.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:name] = 'Test Mixpanel API'
          element[:token] = 'for test'
        end
        FunnelStep.update_data(arr_obj)
        funnel = Funnel.find_by_token_and_at_date(@token_2,"2011-05-16")
        obj_1 = FunnelStep.find_by_goal_and_funnel_id("Test MixPanel API",funnel[:id].to_s)
        obj_1.overall_conv_ratio.should == "3.0"
#      check count of record, should increase by 1
      end.should change(FunnelStep, :count).by(12)
    end

    it "should get data from source table correctly" do
      FunnelStep.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(FunnelStep, "SPEC")
        funnel = Funnel.find_by_token_and_at_date(@token_2,"2011-05-16")
        obj_1 = FunnelStep.find_by_goal_and_funnel_id("Test MixPanel API",funnel[:id].to_s)
        obj_1.overall_conv_ratio.should == "3.0"
      end.should change(FunnelStep, :count).by(32)
    end
  end
end

