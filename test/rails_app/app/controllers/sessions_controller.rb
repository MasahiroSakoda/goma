class SessionsController < ApplicationController

  # GET /sessions/new
  def new
    @user = User.new
  end

  # POST /sessions
  def create
     if @user = user_login(params[:username_or_email], params[:password], params[:remember_me])
      redirect_back_or_to root_url, notice: 'Login successful'
    else
      if goma_error(:user) == :not_activated
        flash.now[:alert] = 'Not activated'
      else
        flash.now[:alert] = 'Login failed'
      end
      render :new
    end
  end

  # DELETE /sessions
  def destroy
    user_logout
    redirect_to root_url, notice: "Logged out!"
  end
end
