class UsersController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = 'Successfully created'
      redirect_to root_url
    else
      render :new
    end
  end

  def activate
    @user = User.load_from_activation_token(params[:id])
    @user.activate!
    flash[:notice] = 'Successfully activated.'
    redirect_to root_url
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
