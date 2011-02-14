require "logger"
require File.expand_path("../stage", __FILE__)

logger = Logger.new(File.expand_path("../../log/#{STAGE}.log",__FILE__))
