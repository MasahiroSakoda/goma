class UsersController < ApplicationController
  before_action :require_user_login, only: [:edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    not_authenticated unless current_user = @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to new_session_url, notice: "You have signed up successfully. However, we could not sign you in because your account is not yet activated. You will receive an email with instructions about how to activate your account in a few minutes."
    else
      update_email or render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    not_authenticated unless current_user = @user
    if @user.update(user_params)
      flash[:notice] = @user.raw_confirmation_token ?
                       'You updated your account successfully, but we need to verify your new email address. Please check your email and click on the confirmation link to finalize confirming your new email address.' :
                       'You updated your account successfully'
      redirect_to @user
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    not_authenticated unless current_user = @user
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def update_email
      @user = User.find_by(username: params[:user][:username])
      if @user.activated?
        return false
      end

      if ( Time.now <= @user.confirmation_token_sent_at + 259200 ) &&
        !@user.valid_password?(params[:user][:password])
        flash[:alert] = 'This username was already registered. If you want to change your email address, please make sure you entered correct password.'
        return false
      end

      @user.resend_activation_needed_email(to: params[:user][:email])
      redirect_to new_session_url
    end
end
