class MapController < ApplicationController
  skip_authorization_check only: [:index, :embed]

  def index
    # do not use `current_or_guest_user` due to it creates the user
    @notifications = current_user&.notifications
    @notifications ||= guest_user? ? current_or_guest_user.notifications : []

    # Show welcome message only first time
    if  ['t', 'true', '1'].include?(params[:welcome])
      cookies.delete :welcome_message_displayed
      redirect_to root_path, params.except(:welcome)
      return
    end

    @show_welcome_mesage = !cookies[:welcome_message_displayed]
    cookies[:welcome_message_displayed] = { value: true, expires: 1.day.from_now.beginning_of_day }
  end

  def embed
    response.headers["X-FRAME-OPTIONS"] = "ALLOWALL"
    # do not use `current_or_guest_user` due to it creates the user
    @notifications = current_user&.notifications
    @notifications ||= guest_user? ? current_or_guest_user.notifications : []

    @local_administration_unit = LocalAdministrationUnit.find(
      params[:local_administration_unit]
    )

    # Show welcome message only first time
    @show_welcome_mesage = ['t', 'true', '1'].include?(params[:welcome])

    render :index, layout: 'embed'
  end
end
