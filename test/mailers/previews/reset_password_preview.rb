
class ResetPasswordPreview < ActionMailer::Preview

  def reset_password_instructions
    user = User.first
    Devise::Mailer.reset_password_instructions(user, user.reset_password_token)
  end

end
