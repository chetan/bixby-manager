
class Rest::BaseController < UiController

  skip_before_filter :bootstrap_current_user
  skip_before_filter :bootstrap_users
  around_action :restful_response

  private

  # Check for a valid user session or API authentication header
  #
  # @return [Boolean] true if the request is not authenticated (user must login)
  def authenticate_user!
    # check for API/signed requests
    if request.headers.env["HTTP_AUTHORIZATION"] || request.headers.env["Authorization"] then
      agent = Agent.where(:access_key => ApiAuth.access_id(request)).first
      begin
        if not(agent and ApiAuth.authentic?(request, agent.secret_key)) then
          return render :text => Bixby::JsonResponse.new("fail", "authentication failed", nil, 401).to_json, :status => 401
        end
      rescue ApiAuth::ApiAuthError => ex
        return render :text => Bixby::JsonResponse.new("fail", ex.message, nil, 401).to_json, :status => 401
      end
      @current_user = agent # TODO hrm.. hack much?
      return false
    end

    # authenticate a request from a browser session
    super
  end

  # Handle any thrown exception and return a proper response
  def restful_response

    begin
      res = yield
      if performed? then
        return res
      end

      if request.path_parameters[:action] == "index" && res.kind_of?(ActiveRecord::Relation) && res.respond_to?(:page)
        # automatically apply paging to lists, when possible
        res = res.page(params[:page]).per(params[:per_page])
      end

      return restful(res)

    rescue Exception => ex
      if ex.kind_of? MissingParam then
        return render(:text => ex.message, :status => 400)
      end
      raise
    end

  end

end
