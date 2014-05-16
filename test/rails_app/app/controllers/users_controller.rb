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
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    not_authenticated unless current_user = @user
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
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
end
