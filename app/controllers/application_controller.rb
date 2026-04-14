class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Skip in development/test so local tools and older dev browsers are not blocked with 406.
  allow_browser versions: :modern if Rails.env.production?
end
