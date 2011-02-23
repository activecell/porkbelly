require File.expand_path(File.join(File.dirname(__FILE__), 'boot'))
require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true  
ActionMailer::Base.delivery_method = :smtp  
ActionMailer::Base.prepend_view_path("#{File.expand_path("../../templates", __FILE__)}")
ActionMailer::Base.smtp_settings = {  
  :address   => "smtp.gmail.com",  
  :port      => 587,  
  :domain    => "profitably.com",  
  :authentication => :plain,  
  :user_name      => "tpldev1@gmail.com",  
  :password       => "tpldev1!",  
  :enable_starttls_auto => true  
} 
