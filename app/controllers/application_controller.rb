class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def reject_guest
    if Current.user.is_guest?
      redirect_to recipes_path, alert: "ゲストユーザーはこの操作を行えません"
    end
  end
end