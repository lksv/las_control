class UsersController < ApplicationController
  skip_load_and_authorize_resource only: :create
  skip_authorization_check only: :create


  def create
    raise 'You are already registered!' if signed_in? || !guest_user?
    generated_password = Devise.friendly_token.first(8)
    @user = User.new(
      email: params[:user] && params[:user][:email],
      password: generated_password,
      password_confirmation: generated_password,
      generated_password: generated_password
    )

    @notifications = current_or_guest_user.notifications

    respond_to do |format|
      if @user.save
        sign_in(:user, @user) # Sing in now
        logging_in # Copy data form Guest User to User model

        format.html { redirect_to after_sign_in_path_for(resource) }
        format.js { render :create }
      else
        format.js { render :create_error }
        format.html { render :create_error }
      end
    end
  end
end
