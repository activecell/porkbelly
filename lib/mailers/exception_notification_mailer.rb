require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "mailer"))

module Mailers
  class ExceptionNotificationMailer < ActionMailer::Base
    # send email when exception ocurred
    def exception_notification(site, exception)
      @site = site
      @exception = exception
      mail(
        :to      => "an.nguyen@techpropulsionlabs.com",
        :from    => "fake@domain.com",
        :subject => "[Profitably] Error occured"
      ) do |format|
        format.html
      end
    end
  end
end

