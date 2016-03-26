class EventsController < ApplicationController
  skip_authorization_check only: [:index, :tiles]

  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.accessible_by(current_ability)
  end

  def tiles
    # FIXME - remove it, just now for testing geojson-vt
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"


    @zoom = params[:z].to_i # zoom
    @x = params[:x].to_i
    @y = params[:y].to_i

    if @zoom >= 15
      bbox = GeoConvertor.tile2bounding_box(@zoom, @x, @y)

      @q = Event.ransack(params[:q])
      @events = @q.result.accessible_by(current_ability)

      key = current_user_role_key + params.slice(:z, :x, :y, :q, :q_query).inspect
      @tile = Rails.cache.fetch(key, expires_in: 5.days) do
        Event.to_geojson(
          events: @events, bbox: bbox, zoom: @zoom
        ) do |events|
          if params[:q] && params[:q][:query]
            # filter events by elasticsearch
            document_ids = events.map(&:source_id).uniq
            filtered_document_ids = document_ids.empty? ? [] : Document.elasticsearch_search(
              params[:q][:query],
              fields: ['id'],
              ids: document_ids
            ).per(document_ids.size).results.map(&:id)
            Rails.logger.info "ElasticSearch reduced documents #{document_ids.size} -> #{filtered_document_ids.size}"
            events = events.where(
              source_id: filtered_document_ids
            )
            Rails.logger.info(events.pluck(:id).inspect)
            events
          else
            # no filter, return all event_ids
            events
          end
        end
      end
    else
      @tile = '{"type":"FeatureCollection","features":[]}'
    end
    render json: @tile
  end
end
