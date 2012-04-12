class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    if params[:current_user_name]
      session[:user_id] = User.find_by_name(params[:current_user_name]).try(:id)
    end
    @current_user ||= User.find_by_id(session[:user_id])
  end
end
