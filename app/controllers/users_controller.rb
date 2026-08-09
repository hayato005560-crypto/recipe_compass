class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :reject_guest, only: %i[edit update destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to recipes_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])

    if Current.user != @user
      redirect_to user_path(@user)
    end

  end

  def update
    @user = User.find(params[:id])

    if @user != Current.user
      redirect_to user_path(@user)
      return
    end

    if @user.update(user_params)
      redirect_to @user, notice: "更新に成功しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user != Current.user
      redirect_to user_path(@user)
      return
    end

    @user.update(is_active: false)
    terminate_session
    @user.sessions.destroy_all


    redirect_to root_path
  end

  private
  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :introduction)
  end

    def reject_guest
    if Current.user.is_guest?
      redirect_to recipes_path, alert: "ゲストユーザーはこの操作を行えません"
    end
  end

end
