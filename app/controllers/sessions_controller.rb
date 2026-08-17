class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create guest]
  rate_limit to: 10, within: 3.minutes, only: %i[create guest], with: -> { redirect_to new_session_path, alert: "しばらく時間をおいてから再度お試しください" }

  def new
  end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user&.is_active?
      start_new_session_for user
      redirect_to after_authentication_url, notice: "ログインしました。"
    else
      redirect_to new_session_path, alert: "メールアドレスまたはパスワードが正しくありません。"
    end
  end

  def guest
    user = User.find_or_create_by!(
      email_address: "guest@example.com",
      is_guest: true
    ) do |guest_user|
      guest_user.name = "ゲストユーザー"
      guest_user.password = SecureRandom.urlsafe_base64
    end

    start_new_session_for user
    redirect_to after_authentication_url, notice: "ゲストユーザーとしてログインしました。"
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "ログアウトしました。", status: :see_other
  end
end
