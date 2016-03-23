class MapController < ApplicationController
  skip_authorization_check only: [:index]

  def index
    # do not use `current_or_guest_user` due to it creates the user
    @notifications = current_user&.notifications
    @notifications ||= []
    render layout: 'application-map'
  end
end
