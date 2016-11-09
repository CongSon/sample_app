class UsersController < ApplicationController
  def show
    @user = User.find_by id: params[:id]
    unless @user
      raise ActiveRecord::RecordNotFound.new I18n.t ".not_found"
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = I18n.t ".user_success_message"
      redirect_to @user
    else
      render :new
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end
end
