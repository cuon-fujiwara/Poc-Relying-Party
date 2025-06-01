class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user

  private

  def current_user
    # セッションのユーザーIDに紐づくOpUserが存在しない場合は、ログインしていないとみなす
    @current_user ||= OpUser.find_by(id: session[:user_id]) if session[:user_id]
  end
end
