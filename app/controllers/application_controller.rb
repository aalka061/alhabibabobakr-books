class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Skip in development/test so local tools and older dev browsers are not blocked with 406.
  # Skip for link-preview / social crawlers so they never get 406-unsupported-browser.html (no OG tags).
  if Rails.env.production?
    allow_browser versions: :modern, if: -> { !link_preview_crawler? }
  end

  helper_method :current_user, :user_signed_in?

  private

  # Covers Meta crawlers, WhatsApp/Telegram-style agents, and generic bots not marked by the useragent gem.
  def link_preview_crawler?
    ua = request.user_agent.to_s
    return false if ua.empty?

    ua.match?(
      %r{
        facebookexternalhit|Facebot|
        meta-webindexer|meta-externalads|meta-externalagent|meta-externalfetcher|
        linkedinbot|Twitterbot|slackbot|telegram|whatsapp|
        pinterest|redditbot|discord|embedly|vkshare|skype|
        Googlebot|Google-InspectionTool|Applebot|bingbot|yandex|duckduck|bytespider|
        barkrowler|AhrefsBot|SemrushBot|GPTBot|anthropic|Perplexity|ImagesiftBot
      }ix
    )
  end

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
