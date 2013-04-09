
class SessionsController < UiController

  # display login page
  def new
    if not current_user.nil? then
      redirect_to inventory_path
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

    ret = { :user => User.find_by_email(user_session.email) }
    ret[:redir] = session.delete(:return_to) if session.include? :return_to
    restful ret
  end

  # GET to logout
  def destroy
    current_user_session.destroy if current_user_session
    reset_session
    render :text => "ok"
  end

end
