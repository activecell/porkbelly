require File.expand_path("../../../initializers/mailer", __FILE__)

module Mailers
  class ExceptionNotificationMailer < ActionMailer::Base  
    # send email when exception ocurred
    # TODO: add stacktrace to email body (Hoang)
    def exception_notification(site, exception)
      @site = site
      @exception = exception
      mail(
        :to      => "hoang.nghiem@techpropulsionlabs.com",  
        :from    => "fake@domain.com",  
        :subject => "[Profitably] Error occured",
      ) do |format|
        format.html
      end
    end  
  end  
end
