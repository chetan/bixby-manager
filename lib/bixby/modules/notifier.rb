
module Bixby

# Notify users by various means (e.g., email, SMS, phone)
class Notifier < API

  # Send an email to the given user
  #
  # @param [User] user
  # @param [String] subject
  # @param [String] body
  def send_email(user, subject, body, options = {})
    user = get_model(user, User)
    Pony.mail(
      :to      => user.email,
      :from    => "Bixby",
      :subject => subject,
      :body    => body
    )
  end

  # Send an SMS to the given user
  #
  # @param [User] user
  # @param [String] body
  def send_sms(user, body)
    user = get_model(user, User)
    message = twilio_client.sms.messages.create(
      {:from => '+13475374153', :to => user.phone, :body => body}
    )
  end


  private

  def twilio_client
    @client ||= Twilio::REST::Client.new(BIXBY_CONFIG[:account_sid],
                                         BIXBY_CONFIG[:auth_token])
    @account ||= @client.account
    return @account
  end

end # Notifier
end # Bixby
