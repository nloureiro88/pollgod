class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :gender, :photo, :birthdate, :location, :profession, :hobbies])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :gender, :photo, :birthdate, :location, :profession, :hobbies])
  end

  def after_sign_up_path_for(resource)
    dash_path
  end

  def after_sign_in_path_for(resource)
    dash_path
  end

  protected

  def after_update_path_for(resource)
    dash_path
  end
end
