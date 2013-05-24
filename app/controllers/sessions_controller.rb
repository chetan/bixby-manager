
class SessionsController < UiController

  # display login page
  def new
    if current_user and is_valid_session? then
      # looks we already have a properly logged in user
      bootstrap Host.for_user(current_user)
      return render :index
    end

    # nuke current_user before login
    current_user_session.destroy if current_user_session
  end

  # POST to log in
  def create
    u = params[:username]
    p = params[:password]
    user_session = UserSession.new(:login => u, :password => p, :remember_me => true)
    if not user_session.save then
      return render :text => "error", :status => 401
    end

    ret = { :user => User.find_by_username_or_email(user_session.login) }
    ret[:redir] = URI.parse(session.delete(:return_to)).path if session.include? :return_to
    restful ret
  end

  # POST to logout
  def destroy
    current_user_session.destroy if current_user_session
    reset_session
    head :no_content
  end

end
