
module Archie
  class Mail < ActionMailer::Base

    def forgot_password(user)
      @user  = user
      @token = user.reset_password_token
      send_mail()
    end


    private

    def send_mail
      mail(:template_path => "archie", :to => @user.email, :subject => "Bixby password reset instructions")
    end

  end
end
