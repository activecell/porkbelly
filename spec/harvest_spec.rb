require File.dirname(__FILE__) + "/spec_helper"
require "fetcher"

module Harvest
  module Util
    def self.load_fixture(fixture)
      file = "harvest/#{fixture}.xml"
      return ::SpecHelper::Util.load_fixture(file)
    end
  end
end

describe "Harvest's " do
  describe "initialize" do
    it "should raise exception if credential is invalid" do
      lambda { Fetcher::Harvest::All.new([]) }.should raise_error(ArgumentError)
      lambda { Fetcher::Harvest::All.new({}) }.should raise_error(ArgumentError)
    end

    it "should not raise exception if credential is valid" do
      Fetcher::Harvest::All.new({:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"})
    end
  end

  describe "fetch client" do
    before(:each) do
      Harvest::Client.destroy_all
      @xml = Harvest::Util.load_fixture("clients")
      @credential = {:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"}
      @all = Fetcher::Harvest::All.new(@credential)
      @all.should_receive(:send_request).and_return(@xml)
    end

    it "should insert the client" do
      @all.fetch_clients(@credential).should eql(["489216"])
      fetched_client = Harvest::Client.find_by_target_id("489216")
      fetched_client.should_not be_nil
      fetched_client.target_id.should eql("489216")
      fetched_client.content.should_not be_nil
      fetched_client.content.should_not be_empty
    end
  end

  describe "fetch contact" do
    before(:each) do
      Harvest::Contact.destroy_all
      @xml = Harvest::Util.load_fixture("contacts")
      @credential = {:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"}
      @all = Fetcher::Harvest::All.new(@credential)
      @all.should_receive(:send_request).and_return(@xml)
    end

    it "should insert the contact" do
      @all.fetch_contacts(@credential).should eql(["9"])
      fetched_contact = Harvest::Contact.find_by_target_id("9")
      fetched_contact.should_not be_nil
      fetched_contact.target_id.should eql("9")
      fetched_contact.content.should_not be_nil
      fetched_contact.content.should_not be_empty
    end
  end

  describe "fetch project" do
    before(:each) do
      Harvest::Project.destroy_all
      @xml = Harvest::Util.load_fixture("projects")
      @credential = {:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"}
      @all = Fetcher::Harvest::All.new(@credential)
      @all.should_receive(:send_request).and_return(@xml)
    end

    it "should insert the project" do
      @all.fetch_projects(@credential).should eql(["1"])
      fetched_project = Harvest::Project.find_by_target_id("1")
      fetched_project.should_not be_nil
      fetched_project.target_id.should eql("1")
      fetched_project.content.should_not be_nil
      fetched_project.content.should_not be_empty
    end
  end

  describe "fetch user assignment based on project" do
    before(:each) do
      Harvest::UserAssignment.destroy_all
      @xml = Harvest::Util.load_fixture("user_assignments_for_project_1077512")
      @credential = {:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"}
      @all = Fetcher::Harvest::All.new(@credential)
      @all.should_receive(:send_request).and_return(@xml)
    end

    it "should insert the user assigment" do
      @all.fetch_user_assignments(@credential, "1077512").should eql(["7878790"])
      fetched_user_assignment = Harvest::UserAssignment.find_by_target_id("7878790")
      fetched_user_assignment.should_not be_nil
      fetched_user_assignment.target_id.should eql("7878790")
      fetched_user_assignment.project_id.should eql("1077512")
      fetched_user_assignment.content.should_not be_nil
      fetched_user_assignment.content.should_not be_empty
    end
  end

  describe "fetch task" do
    before(:each) do
      Harvest::Task.destroy_all
      @xml = Harvest::Util.load_fixture("tasks")
      @credential = {:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"}
      @all = Fetcher::Harvest::All.new(@credential)
      @all.should_receive(:send_request).and_return(@xml)
    end

    it "should insert the task" do
      @all.fetch_tasks(@credential).should eql(["1"])
      fetched_task = Harvest::Task.find_by_target_id("1")
      fetched_task.should_not be_nil
      fetched_task.target_id.should eql("1")
      fetched_task.content.should_not be_nil
      fetched_task.content.should_not be_empty
    end
  end

  describe "fetch user" do
    before(:each) do
      Harvest::User.destroy_all
      @xml = Harvest::Util.load_fixture("people")
      @credential = {:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"}
      @all = Fetcher::Harvest::All.new(@credential)
      @all.should_receive(:send_request).and_return(@xml)
    end

    it "should insert the user" do
      @all.fetch_people(@credential).should eql(["54234"])
      fetched_user = Harvest::User.find_by_target_id("54234")
      fetched_user.should_not be_nil
      fetched_user.target_id.should eql("54234")
      fetched_user.content.should_not be_nil
      fetched_user.content.should_not be_empty
    end
  end

  describe "fetch expense category" do
    before(:each) do
      Harvest::ExpenseCategory.destroy_all
      @xml = Harvest::Util.load_fixture("expense_categories")
      @credential = {:username => "utwkidvn@gmail.com", :password => "tpl123456", :subdomain => "tpltest"}
      @all = Fetcher::Harvest::All.new(@credential)
      @all.should_receive(:send_request).and_return(@xml)
    end

    it "should insert the expense category" do
      @all.fetch_expense_categories(@credential).should eql(["Mileage"])
      fetched_expense_category = Harvest::ExpenseCategory.find_by_target_id("Mileage")
      fetched_expense_category.should_not be_nil
      fetched_expense_category.target_id.should eql("Mileage")
      fetched_expense_category.content.should_not be_nil
      fetched_expense_category.content.should_not be_empty
    end
  end

end
