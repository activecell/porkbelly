require "rubygems"
require "bundler/setup"

STAGE = ENV["STAGE_ENV"] || "development"
#ENV['RESTCLIENT_LOG'] ||= File.join(File.dirname(__FILE__), "..", "..", "..", "log", "harvest.log")
ENV['RESTCLIENT_LOG'] ||= File.expand_path(File.join(File.dirname(__FILE__), "..", "log", "request.log"))
