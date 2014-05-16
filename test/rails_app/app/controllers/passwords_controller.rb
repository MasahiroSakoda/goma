class PasswordsController < ApplicationController

  # GET /passwords/new
  def new
    @user = User.new
  end

  # POST /passwords
  def create
    @user = User.find_by_identifier(params[:username_or_email])
    @user.send_reset_password_instructions! if @user

    flash[:notice] = "You will receive an email with instructions about how to reset your password in a few minutes."
    redirect_to new_session_url
  end

  # GET /passwords/1/edit
  def edit
    @user = User.new
    @user.raw_reset_password_token = params[:id]
  end

  # PATCH/PUT /passwords/1
  def update
    @user, err = User.load_from_reset_password_token_with_error(params[:user][:raw_reset_password_token])

    if @user
      @user.unlock_access! if @user.lockable? && @user.access_locked?
      @user.change_password!(params[:user][:password], params[:user][:password_confirmation])
      force_login(@user)
      redirect_back_or_to root_url, notice: 'Your password was changed successfully. You are now logged in.'
    else
      if err == :token_expired
        flash.now[:alert] = "The password reset URL you visited has expired, please request a new one."
        render :new
      else
        @user = User.new
        flash.now[:alert] = "You can't change your password in this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided."
        render :edit
      end
    end
  rescue ActiveRecord::RecordInvalid
    @user.raw_reset_password_token = params[:user][:raw_reset_password_token]
    render :edit
  end
end
