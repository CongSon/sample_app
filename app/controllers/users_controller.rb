class UsersController < ApplicationController
  before_action :logged_in_user, except: [:show, :new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def show
    @user = User.find_by id: params[:id]
    @microposts = @user.microposts.paginate page: params[:page]
    unless @user
      render_404
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = I18n.t ".mail_info"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit
    @user = User.find_by id: params[:id]
    unless @user
      render_404
    end
  end

  def update
    @user = User.find_by id: params[:id]
    if @user.update_attributes user_params
      flash[:success] = I18n.t ".update_success"
      redirect_to @user
    else
      render :edit
    end
  end

  def index
    @users = User.page(params[:page]).order(created_at: :ASC)
  end

  def destroy
    User.find_by(id: params[:id]).destroy
    flash[:success] = I18n.t ".delete_success"
    redirect_to users_url
  end

  def following
    @title = I18n.t ".following"
    @user  = User.find_by id: params[:id]
    @users = @user.following.page(params[:page]).order(created_at: :DESC)
    render :show_follow
  end

  def followers
    @title = I18n.t ".followers"
    @user  = User.find_by id: params[:id]
    @users = @user.followers.page(params[:page]).order(created_at: :DESC)
    render :show_follow
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end

  def correct_user
    @user = User.find_by id: params[:id]
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def render_404
    render file: "#{Rails.root}/public/404.html",  status: 404
  end
end
