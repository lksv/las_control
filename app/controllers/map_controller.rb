class MapController < ApplicationController
  skip_authorization_check only: [:index]

  def index
    # do not use `current_or_guest_user` due to it creates the user
    @notifications = current_user&.notifications
    @notifications ||= guest_user? ? current_or_guest_user.notifications : []

    # Show welcome message only first time

    @show_welcome_mesage = !cookies[:welcome_message_displayed]
    cookies[:welcome_message_displayed] = { value: true, expires: 1.day.from_now.beginning_of_day }

    render layout: 'application-map'
  end
end
