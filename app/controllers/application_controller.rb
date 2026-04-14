class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Skip in development/test so local tools and older dev browsers are not blocked with 406.
  allow_browser versions: :modern if Rails.env.production?

  helper_method :current_user, :user_signed_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def require_authentication
    return if user_signed_in?

    path = request.fullpath
    session[:after_login_return_to] = path if path.start_with?("/") && !path.start_with?("//")
    redirect_to login_path, alert: "يرجى تسجيل الدخول لتعديل البيانات."
  end
end
