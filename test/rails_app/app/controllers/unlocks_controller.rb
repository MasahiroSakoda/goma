class UnlocksController < ApplicationController

  # GET /unlocks/1
  def show
    @user, err = User.load_from_unlock_token_with_error(params[:id])
    if @user
      flash[:notice] = "Your account has been unlocked successfully. Please continue to login."
      redirect_to new_session_url
    else
      if err == :token_expired
        flash.now[:alert] = "The unlock URL you visited has expired, please request a new one."
      else
        flash.now[:alert] = "Not found any account by this URL."
      end
      render :new
    end
  end

  # GET /unlocks/new
  def new
    @user = User.new
  end

  # POST /unlocks
  def create
    @user = User.find_by_identifier(params[:username_or_email])
    @user.send_unlock_instructions!

    flash[:notice] = 'Instructions have been sent to your email.'
    redirect_to new_session_url
  end
end
