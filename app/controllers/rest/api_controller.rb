
class Rest::ApiController < UiController

  around_action :catch_exceptions

  private

  # Check for a valid user session or API authentication header
  #
  # @return [Boolean] true if the request is not authenticated (user must login)
  def authenticate_user!
    # check for API/signed requests
    if request.headers.env["HTTP_AUTHORIZATION"] || request.headers.env["Authorization"] then
      agent = Agent.where(:access_key => ApiAuth.access_id(request)).first
      if not(agent and ApiAuth.authentic?(request, agent.secret_key)) then
        return render :text => Bixby::JsonResponse.new("fail", "authentication failed", nil, 401).to_json, :status => 401
      end
      @current_user = agent # hrm.. hack much?
      return false
    end

    super
  end

  # Handle any thrown exception and return a proper response
  def catch_exceptions

    begin
      yield
    rescue Exception => ex
      if ex.kind_of? MissingParam then
        return render(:text => ex.message, :status => 400)
      end
      raise
    end

  end

end
