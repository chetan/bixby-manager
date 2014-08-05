
class ResetPasswordPreview < ActionMailer::Preview

  def forgot_password
    user = User.first
    user.reset_password_token   = Archie.generate_token
    user.reset_password_sent_at = Time.new
    user.save

    ret = Archie::Mail.forgot_password(user)

    return ret
  end

end
