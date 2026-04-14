class SessionsController < ApplicationController
  def new
    redirect_to root_path if user_signed_in?
  end

  def create
    user = User.authenticate_by(email: params[:email].to_s, password: params[:password].to_s)
    if user
      reset_session
      session[:user_id] = user.id
      redirect_to(session.delete(:after_login_return_to) || root_path)
    else
      flash.now[:alert] = "البريد الإلكتروني أو كلمة المرور غير صحيحة."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "تم تسجيل الخروج."
  end
end
