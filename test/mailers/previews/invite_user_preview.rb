
class InviteUserPreview < ActionMailer::Preview

  def invite_user
    user = User.new
    user.org_id = Org.first.id
    user.email = "foo@example.com"
    user.username = "foo"
    user.invite_token = Archie.generate_token
    user.invite_created_at = Time.new
    user.invite_sent_at = Time.new
    user.save!

    Archie::Mail.invite_user(user)
  end

end
