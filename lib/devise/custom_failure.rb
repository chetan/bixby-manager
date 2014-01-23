
module Devise

  class CustomFailure < FailureApp

    protected

    def redirect_url
      if warden_message == :timeout then
        super
      else
        "/login"
      end
    end

  end

end
