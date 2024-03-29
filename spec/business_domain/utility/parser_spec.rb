require File.dirname(__FILE__) + "/spec_helper"

describe "::BusinessDomain::Parser" do

  before :all do
      @xml = ::Pivotal::Util.load_fixture("activities")
      @params = {}
      @params[:mapper] = [[:target_id,'id'],
          [:version,'version'],
          [:event_type,'event_type'],
          [:occurred_at,'occurred_at'],
          [:author,'author'],
          [:project_id, 'project_id'],
          [:description,'description']]
      @params[:parent] = "activities/activity"
      @params[:key_field] = :target_id
  end

  describe "Parse Method" do
    it "should parse XML to array" do
      result = Parser.parse(@xml,@params)
      result.should be_kind_of(Array)
    end

    it "should parse nodes of XML to array of hashes" do
      result = Parser.parse(@xml,@params)
      result.each do |ele|
        ele.should be_kind_of(Hash)
      end
    end

    it "should parse nodes of XML to array of hashes and sub array" do
      params = {}
      params[:mapper] = [[:target_id,'id'],
                        [:version,'version'],
                        [:event_type,'event_type'],
                        [:occurred_at,'occurred_at'],
                        [:author,'author'],
                        [:project_id, 'project_id'],
                        [:description,'description'],
                        [:arr_story_id,'stories//story']]
      params[:parent] = "activities/activity"
      params[:key_field] = :target_id
      params[:be_array] = [:arr_story_id,'id']
      result = Parser.parse(@xml,params)
      result.each do |ele|
        ele[:arr_story_id].should be_kind_of(Array)
        ele.should be_kind_of(Hash)
      end
      result[0][:arr_story_id].should =~ ["9963685"]
    end

    it "should parse nodes of XML to elements correctly" do
      result = Parser.parse(@xml,@params)
#      test multi element
      result.each do |ele|
        ele[:target_id].should_not be_empty
        ele[:author].should == "Chuong Huynh"
      end
#      test first element value
      result[0][:target_id].should == "59596685"
      result[0][:version].should == "567"
      result[0][:event_type].should == "story_update"
      result[0][:occurred_at].should == "2011/02/28 03:05:10 UTC"
      result[0][:project_id].should == "136215"
      result[0][:description].should == "Chuong Huynh accepted \"Can't create issue for iteration\""
    end
    
    it "should parse JSON string to hash with params" do
      json = ::Mixpanel::Util.load_fixture("parsed_events")
      json_params = {}
      json_params[:root] = "data/values"
      json_params[:key] = :at_date
      json_params[:value] = :srv_count
      json_params[:block] = lambda {|content|
            object = []
            data = JSON content
            roots = json_params[:root].split('/')
            roots.each {|element| data = data[element]}
            
            data.each do |key, value| 
              data[key].each do |a|
                next if a[1] == 0
                element = {}
                element.update json_params[:key] => a[0]
                element.update json_params[:value] => a[1]
                object.push element
              end
            end
            object
          }
      result = Parser.parse(json, json_params, "SPEC")
      result[0][:at_date].should == "2011-04-27"
      result[0][:srv_count].should == 1
    end
  end

  describe "Get Content Method" do

    before :all do
      @xml_1 = ::Pivotal::Util.load_fixture("activity_1")
      @xml_2 = ::Pivotal::Util.load_fixture("activity_2")
      @target_id = ["59596685","59596663"]
      record = ::PivotalTracker::Activity.find_or_initialize_by_target_id_and_credential("59596685","d0f12bb1ac3d8f1867278620dda90dbb")
      record.content = @xml_1
      record.update_attributes(record)
      record = ::PivotalTracker::Activity.find_or_initialize_by_target_id_and_credential("59596663","d0f12bb1ac3d8f1867278620dda90dbb")
      record.content = @xml_2
      record.update_attributes(record)
      @params[:parent] = "activity"
    end

    it "should get values from source data correctly" do
      arr_obj = Parser.get_content(::PivotalTracker::Activity,@params)
      arr_obj.each do |element|
        element[0][:target_id].should_not be_empty
        element[0][:author].should == "Chuong Huynh"
      end
      result = arr_obj[0]
      result[0][:target_id].should == "59596685"
      result[0][:version].should == "567"
      result[0][:event_type].should == "story_update"
      result[0][:occurred_at].should == "2011/02/28 03:05:10 UTC"
      result[0][:project_id].should == "136215"
      result[0][:description].should == "Chuong Huynh accepted \"Can't create issue for iteration\""
    end

    it "should return nil when content is not matched" do
      @params[:parent] = "activities/activity" # change node position, won't find matched data
      arr_obj = Parser.get_content(::PivotalTracker::Activity,@params)
      arr_obj.should be_nil
    end

  end

  describe "Parse All Method" do

    it "should parse all records" do
      Parser.parse_all(::BusinessDomain::PivotalTracker::Activity)
      sample = ::BusinessDomain::PivotalTracker::Activity.find_by_target_id("59596685")
      sample.version.should == "567"
      sample.event_type.should == "story_update"
      sample.occurred_at.should == "2011/02/28 03:05:10 UTC"
      sample.project_id.should == "136215"
      sample.description.should == "Chuong Huynh accepted \"Can't create issue for iteration\""
      # second record
      sample = ::BusinessDomain::PivotalTracker::Activity.find_by_target_id("59596663")
      sample.version.should == "566"
      sample.event_type.should == "story_update"
      sample.occurred_at.should == "2011/02/28 03:04:49 UTC"
      sample.project_id.should == "136215"
      sample.description.should == "Chuong Huynh accepted \"Include a free text \"Summary\" field in daily report\""
    end
  end
end

