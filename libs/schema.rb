require File.expand_path("../../initializers/database", __FILE__)
require File.expand_path("../../initializers/logger", __FILE__)

class User < ActiveRecord::Base
end

puts User.count
