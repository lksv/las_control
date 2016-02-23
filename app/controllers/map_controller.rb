class MapController < ApplicationController
  skip_authorization_check only: [:index]

  def index
    render layout: 'application-map'
  end
end
