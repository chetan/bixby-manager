
class SessionsController < UiController

  # display login page
  def new
  end

  # POST to log in
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
    session[:logged_in] = user.id

    render :text => "success"
  end

  # GET to logout
  def destroy
    session.delete :logged_in
    render :text => "ok"
  end

end
