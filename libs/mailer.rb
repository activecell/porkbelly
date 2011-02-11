require "rubygems"
require "bundler/setup"
require "action_mailer"

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "adobesplc.com",
  :authentication       => :plain,
  :user_name            => "adobesplc@gmail.com",
  :password             => "adobe12345"
}
#ActionMailer::Base.server_settings {
  #:address => ‘blah.com’ # your email server here
  #:port => 25
  #:domain => ‘blah’ # This is the name which will be given to the email server during the HELO
#}
#ActionMailer::Base.template_root = "mailer"

# creating a class by subclassing ActionMailer
class StandAloneEmailSender < ActionMailer::Base
  def confirm()
    @subject = "Email from stand alone Ruby program"
    @recipients = ["hoang.nghiem@techpropulsionlabs.com"]
    @from = "developer@blah.com"
    @header["x-mailer"] = "Ruby ActionMailer"
    @body["receiver"] = "Mr. Deeds"
  end
end
StandAloneEmailSender.confirm
