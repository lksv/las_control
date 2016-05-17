require 'geo_convertor'

class EventsController < ApplicationController

  skip_authorization_check only: [:index, :public_tiles]
  before_filter :set_tiles_params, :validate_zoom, only: [:tiles, :public_tiles, :document_ids]

  caches_page :public_tiles, gzip: true

  def index
    @q = Event.ransack(params[:q])
    @events = @q.result.accessible_by(current_ability)
  end

  def tiles
    authorize! :read, Event

    key = current_user_role_key + ['tiles', @zoom, @x, @y, @q].inspect
    @tile = Rails.cache.fetch(key, expires_in: expires_in_time) do
      get_tile(@zoom, @x, @y, @q, current_ability)
    end
    render json: @tile
  end

  def public_tiles
    key = current_user_role_key + ['public_tiles', @zoom, @x, @y, @q].inspect
    # caching here is only for development environment.
    # In production cache whole page nginx
    @tile = Rails.cache.fetch(key, expires_in: expires_in_time) do
      @tile = get_tile(@zoom, @x, @y, @q, public_ability)
    end
    expires_in(expires_in_time, public: true)
    render json: @tile
  end

  # GET http://localhost:3000/tiles/13/4423/2775/document_ids.json?q[query]=praha
  #
  def document_ids
    authorize! :read, Event
    bbox = GeoConvertor.tile2bounding_box(@zoom, @x, @y)

    key = current_user_role_key + ['tiles', @zoom, @x, @y, @q, 'document_ids'].inspect
    res = Rails.cache.fetch(key, expires_in: expires_in_time) do

      document_ids = Rails.cache.fetch(
        current_user_role_key + ['tiles', @zoom, @x, @y, 'ids'].inspect,
        expires_in: expires_in_time
      ) do
        Event
          .accessible_by(current_ability)
          .joins(:shape).merge(Shape.in_bounding_box(bbox))
          .group(:source_id).pluck(:source_id)
      end

      query = params[:q].try(:[], :query)
      Rails.logger.debug(query.inspect);
      if query.blank?
        Rails.logger.warn('Query is blank!');
        document_ids
      else
        Document.elasticsearch_search(
          query,
          fields: ['id'],
          ids: document_ids
        ).per(document_ids.size).results.map { |i| i.id.to_i }
      end
    end
    expires_in(expires_in_time, public: true)

    render json: res
  end

  private

  def expires_in_time
    Time.now.end_of_day - Time.now
  end

  def validate_zoom
    render(status: 422, json: {message: 'Not allowed zoom'}) unless @zoom == 13
  end

  def set_tiles_params
    @zoom = params[:z].to_i # zoom
    @x = params[:x].to_i
    @y = params[:y].to_i
    @q = params[:q]
  end

  def get_tile(zoom, x, y, query, ability)
    bbox = GeoConvertor.tile2bounding_box(zoom, x, y)

    q = Event.ransack(query)
    events = q.result.accessible_by(ability)

    Event.to_geojson(
      events: events, bbox: bbox, zoom: zoom
    ) do |events|
      if query && query[:query]
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
        events
      else
        # no filter, return all event_ids
        events
      end
    end
  end

end
