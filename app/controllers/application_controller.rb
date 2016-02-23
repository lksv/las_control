class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  check_authorization :unless => :devise_controller?

  def current_user_role_key
    return 'anonymous' unless current_user
    [
      current_user.role.to_s,
      current_user.local_administration_unit_admins.map do |laur|
        "#{laur.local_administration_unit_id}:#{laur.role}"
      end
    ].join('::')
  end
end
