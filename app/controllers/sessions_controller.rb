
class SessionsController < UiController

  # display login page
  def new
    if not current_user.nil? then
      redirect_to root_path
    end
  end

  # POST to log in
  def create
    u = params[:username]
    p = params[:password]
    user_session = UserSession.new(:email => u, :password => p, :remember_me => true)
    if not user_session.save then
      return render :text => "error", :status => 401
    end
    restful User.find_by_email(user_session.email)
  end

  # GET to logout
  def destroy
    current_user_session.destroy if current_user_session
    session.clear
    render :text => "ok"
  end

end
