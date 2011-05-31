require File.dirname(__FILE__) + "/spec_helper"
require 'digest/md5'

include  ::BusinessDomain::GA

describe "::BusinessDomain::GA::Account" do

  describe "Update Data Method" do
    before :all do
      @xml_1 = ::GA::Util.load_fixture("profile_1")
      @xml_2 = ::GA::Util.load_fixture("profile_2")
      @xml_1_changed = ::GA::Util.load_fixture("profile_1_changed")
      @params = {}
      @params[:change] = [:account_id, :account_id]
      @params[:field_pos] = :entry
      @params[:block] = lambda {|content|
            contain = []
            doc = Nokogiri::XML(content)
            doc.remove_namespaces!
            element = {}
            element.update :title => doc.xpath('//title').text
            doc.xpath("//*").each do |ele|
              name = ele.xpath("@name").text
              if !name[3..-1].nil?
                cut_name = name[3..-1]
                sym = cut_name.to_sym 
                element.update(sym => ele.xpath("@value").text) if Profile.column_names.include? cut_name
              end
            end
            contain.push(element)
            return contain
          }
#      fill data to source table
      GA::Account.destroy_all
      record = ::GA::Account.new
      record.content = @xml_1
      record.entry = @xml_1
      record.credential = '{:username=>"utwkidvn@gmail.com"}'
      record.table_id = "ga:42991252"
      record.account_id = 21764954
      record.update_attributes(record)
      record = ::GA::Account.new
      record.content = @xml_2
      record.entry = @xml_2
      record.credential = '{:username=>"utwkidvn@gmail.com"}'
      record.table_id = "ga:42990694"
      record.account_id = 21764954
      record.update_attributes(record)
      
    end

    it "should update data to table when same account_id and date" do
#      reset table
        Profile.destroy_all
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:account_id] = '21764954'
        end
        Profile.update_data(arr_obj)
        obj_1 = Profile.find_by_account_id_and_profileId('21764954',"42991252")
#      second sample
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_1_changed,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:account_id] = '21764954'
        end
        Profile.update_data(arr_obj)
        obj_2 = Profile.find_by_account_id_and_profileId('21764954',"42991252")
#      compariation
        obj_1.title.should == "profitably.heroku.com/"
        obj_2.title.should == "changed"
#      check count of record, should unchange
      end.should change(Profile, :count).by(0)
    end

    it "should insert data when new account_id and date" do
#      reset table
      Profile.destroy_all
      lambda do
        arr_obj = []
        arr_obj.push Parser.parse(@xml_2,@params, "SPEC")
        arr_obj[0].each do |element| 
          element[:account_id] = '21764954'
        end
        Profile.update_data(arr_obj)
        obj_1 = Profile.find_by_account_id_and_profileId('21764954',"43683834")
        obj_1.title.should == "tpl-dev.blogspot.com/"
#      check count of record, should increase by 1
      end.should change(Profile, :count).by(1)
    end

    it "should get data from source table correctly" do
      Profile.destroy_all
#      get data and update
      lambda do
        Parser.parse_all(Profile, "SPEC")
        obj_1 = Profile.find_by_account_id_and_profileId('21764954',"43683834")
        obj_1.title.should == "tpl-dev.blogspot.com/"
      end.should change(Profile, :count).by(2)
    end
  end
end

