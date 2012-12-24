
class SessionsController < UiController

  # display login page
  def new
  end

  # POST to login
  def create
    u = params[:username]
    p = params[:password]
    if u.blank? or p.blank? then
      return render :text => "error", :status => 401
    end

    user = User.where(:email => u).first
    if user.nil? then
      # doesn't exist
    end

    if not user.test_password(p) then
      # bad pass
    end

    # TODO replace with proper auth/session (authlogic?)
    session[:logged_in] = true

    render :text => "success"
  end

  # GET to logout
  def destroy
  end

end
