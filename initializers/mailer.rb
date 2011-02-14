require File.expand_path("../../initializers/boot", __FILE__)
require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true  
ActionMailer::Base.delivery_method = :smtp  
ActionMailer::Base.template_root = "#{File.expand_path("../../mailer", __FILE__)}"
ActionMailer::Base.prepend_view_path("#{File.expand_path("../../mailer", __FILE__)}")
ActionMailer::Base.smtp_settings = {  
   :address   => "smtp.gmail.com",  
   :port      => 587,  
   :domain    => "adobesplc.com",  
   :authentication => :plain,  
   :user_name      => "adobesplc@gmail.com",  
   :password       => "adobe12345",  
   :enable_starttls_auto => true  
  }  
  
class BugMailer < ActionMailer::Base  
  def exception_notification
    @msg = "asldfjasdlasdlfjasl"
    mail(  
      :to      => "hoang.nghiem@techpropulsionlabs.com",  
      :from    => "fake@domain.com",  
      :subject => "testing mail" 
    )  
  end  
end  
  
puts "#{File.expand_path("../../mailer", __FILE__)}"
#BugMailer.exception_notification.deliver  
debugger
puts BugMailer.exception_notification
