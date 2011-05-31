require File.dirname(__FILE__) + "/spec_helper"
require 'digest/md5'

include  ::BusinessDomain::GA

describe "::BusinessDomain::GA::Entry" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::GA::Util.load_fixture("data_1")
      @xml_2 = ::GA::Util.load_fixture("data_2")
      @xml_1_changed = ::GA::Util.load_fixture("data_1_changed")
      
      @xml_1_prf = ::GA::Util.load_fixture("profile_1")
      @xml_2_prf = ::GA::Util.load_fixture("profile_2")
      @xml_1_changed_prf = ::GA::Util.load_fixture("profile_1_changed")
      
      @params = {}
      @params[:root] = "data/values"
      @params[:mapper] = [[:visitorType,'ga:visitorType'],
                          [:pagePath,'ga:pagePath'],
                          [:date,'ga:date'],
                          [:referralPath,'ga:referralPath'],
                          [:campaign,'ga:campaign'],
                          [:source,'ga:source'],
                          [:hostname,'ga:hostname'],
                          [:pagePath,'ga:pagePath'],
                          [:visitors,'ga:visitors'],
                          [:visits,'ga:visits'],
                          [:pageviews,'ga:pageviews'],
                          [:pageviewsPerVisit,'ga:pageviewsPerVisit'],
                          [:uniquePageviews,'ga:uniquePageviews'],
                          [:avgTimeOnPage,'ga:avgTimeOnPage'],
                          [:avgTimeOnSite,'ga:avgTimeOnSite'],
                          [:entrances,'ga:entrances'],
                          [:exits,'ga:exits'],
                          [:organicSearches,'ga:organicSearches'],
                          [:impressions,'ga:impressions'],
                          [:adClicks,'ga:adClicks'],
                          [:adCost,'ga:adCost'],
                          [:CPM,'ga:CPM'],
                          [:CPC,'ga:CPC'],
                          [:CTR,'ga:CTR'],
                          [:costPerGoalConversion,'ga:costPerGoalConversion'],
                          [:costPerTransaction,'ga:costPerTransaction'],
                          [:costPerConversion,'ga:costPerConversion'],
                          [:RPC,'ga:RPC']]
      @params[:change] = [[:account_id, :account_id],[:profile_id,:table_id]]
      @params[:block] = lambda {|content|
            contain = []
            doc = Nokogiri::XML(content)
            doc.remove_namespaces!
            doc.xpath("//entry").each do |node|
              element = {}
              node.xpath("*").each do |ele|
                name = ele.xpath("@name").text
                sym = name[3..-1].to_sym if !name[3..-1].nil?
                element.update(sym => ele.xpath("@value").text) if @params[:mapper].include? [sym,name]
              end
              contain.push(element)
            end
            return contain
          }
          
      GA::Account.destroy_all
      GA::Data.destroy_all
      # fill data to source table
      record = ::GA::Data.new
      record.content = @xml_1
      record.credential = '{:username=>"utwkidvn@gmail.com"}'
      record.table_id = "ga:42991252"
      record.account_id = 21764954
      record.update_attributes(record)
      record = ::GA::Data.new
      record.content = @xml_2
      record.credential = '{:username=>"utwkidvn@gmail.com"}'
      record.table_id = "ga:43683834"
      record.account_id = 21764954
      record.update_attributes(record)
      # Profile
      record = ::GA::Account.new
      record.content = @xml_1_prf
      record.entry = @xml_1_prf
      record.credential = '{:username=>"utwkidvn@gmail.com"}'
      record.table_id = "ga:42991252"
      record.account_id = 21764954
      record.update_attributes(record)
      record = ::GA::Account.new
      record.content = @xml_2_prf
      record.entry = @xml_2_prf
      record.credential = '{:username=>"utwkidvn@gmail.com"}'
      record.table_id = "ga:43683834"
      record.account_id = 21764954
      record.update_attributes(record)
      
      Parser.parse_all(Profile, "SPEC")
      
    end

    it "should update data to table when same account_id and date" do
#      reset table
        Entry.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:account_id] = '21764954'
          element[:profile_id] = "ga:42991252"
        end
        puts "==============> #{arr_obj.inspect}"
        Entry.update_data(arr_obj)
        obj_1 = Entry.find(:last)
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:account_id] = '21764954'
          element[:profile_id] = "ga:42991252"
        end
        puts "==============> #{arr_obj.inspect}"
        Entry.update_data(arr_obj)
        obj_2 = Entry.find(:last)
#      compariation
        obj_1.visits.should == "1"
        obj_2.visits.should == "6"
#      check count of record, should unchange
      end.should change(Entry, :count).by(0)
    end
    it "should insert data when new account_id and date" do
#      reset table
      Entry.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:account_id] = '21764954'
          element[:profile_id] = "ga:43683834"
        end
        Entry.update_data(arr_obj)
        obj_1 = Entry.find(:last)
        obj_1.visits.should == "10"
#      check count of record, should increase by 1
      end.should change(Entry, :count).by(1)
    end
    
    it "should get data from source table correctly" do
      Entry.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Entry, "SPEC")
        obj_1 = Entry.find(:last)
        obj_1.visits.should == "10"
      end.should change(Entry, :count).by(2)
    end
  end
end

