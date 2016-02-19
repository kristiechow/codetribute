class SessionsController < ApplicationController
  skip_before_action :ensure_current_user

  def new
  end

  def create
    if request.env["omniauth.auth"]
      auth = request.env["omniauth.auth"]
      session[:omniauth] = auth.except('extra')
      user = User.sign_in_from_omniauth(auth)
      session[:user_id] = user.id
      redirect_to root_path
    else
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash.notice = "Welcome back to Build my Business #{user.first_name}"
      redirect_to root_path
    else
      flash[:error] = 'Login unsuccessful'
      render :new
    end
  end
end

  def destroy
    session[:user_id] = nil
    session[:omniauth] = nil
    redirect_to root_path, notice: "Log out successful"
  end
end

