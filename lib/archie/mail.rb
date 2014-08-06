
module Archie
  class Mail < ActionMailer::Base

    def forgot_password(user)
      @user  = user
      @token = user.reset_password_token
      send_mail("Bixby password reset instructions")
    end

    def invite_user(user, invited_by=nil)
      @user = user
      @token = user.invite_token
      @invited_by = invited_by
      send_mail("Welcome to Bixby!")
    end


    private

    def send_mail(subject)
      mail(:template_path => "archie",
           :from => BIXBY_CONFIG[:mailer_from],
           :to => @user.email,
           :subject => subject)
    end

  end
end
