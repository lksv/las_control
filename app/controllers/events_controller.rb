class EventsController < ApplicationController
  skip_authorization_check only: [:index, :tiles]

  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.accessible_by(current_ability)
  end

  def tiles
    @zoom = params[:z].to_i # zoom
    @x = params[:x].to_i
    @y = params[:y].to_i
    bbox = GeoConvertor.tile2bounding_box(@zoom, @x, @y)

    @q = Event.ransack(params[:q])
    @events = @q.result.accessible_by(current_ability)

    key = current_user_role_key + params.inspect + 'sdfxx'
    @tile = Rails.cache.fetch(key, expires_in: 2.hours) do
      Event.to_geojson(
        events: @events,
        bbox: bbox,
        zoom: @zoom
      )
    end
    render json: @tile
  end
end
