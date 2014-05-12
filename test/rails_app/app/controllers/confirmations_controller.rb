class ConfirmationsController < ApplicationController
  # GET /confirmations/new
  def new
    @user= User.new
  end


  # POST /confirmations
  def create
    @user = User.find_by_identifier(params[:username_or_email])
    @user.generate_confirmation_token
    @user.send_activation_needed_email

    redirect_to new_session_url, notice: "We are processing your request. You will receive new activation email in a few minutes."
  end


  # GET /confirmations/1
  def show
    @user, err = User.load_from_activation_token_with_error(params[:id])

    if @user
      @user.activate!
      redirect_to new_session_url, notice: 'Your account was successfully activated.'
    else
      if err == :token_expired
        flash.now[:alert] = "Your activation URL has expired, please request a new one."
      else
        flash.now[:alert] = "Not found any account by this URL. Please make sure you used the full URL provided."
      end
      render :new
    end
  end


  # GET /confirmations/1/email
  def email
    @user, err = User.load_from_email_confirmation_token_with_error(params[:id])

    if @user
      @user.confirm_email!
      redirect_to edit_user_url, notice: 'Your new email was successfully confirmed.'
    else
      if err == :token_expired
        flash.now[:alert] = "Your email confirmation URL has expired, please change your email again."
      else
        flash.now[:alert] = "Email confirmation failed. Please make sure you used the full URL provided."
      end
      render edit_user_url(current_user)
    end
  end
end
