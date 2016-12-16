class ShapesController < ApplicationController
  load_and_authorize_resource

  caches_page :public_show, gzip: true

  # Some shapes has got a lot of events see
  # http://localhost:3000/shapes/3581, e.g. event of address:
  # http://localhost:3000/map#18/50.08363/14.47006
  # which takes around 2.3s to render
  def show
    if params[:event_ids]
      event_ids = params[:event_ids].split(',').map(&:to_i)
      @events = Event.accessible_by(current_ability).find(event_ids)
    else
      @events = @shape
        .events
        .accessible_by(current_ability)
        .includes(:address_block, source: :local_administration_unit)
    end

    respond_to do |format|
      format.html { render layout: false }
      format.xml  { render xml: @events }
      format.json { render json: @events }
    end
  end

  def public_show
    @events = @shape
      .events
      .accessible_by(public_ability)
      .includes(:address_block, source: :local_administration_unit)

    respond_to do |format|
      format.html { render :show, layout: false }
      format.xml  { render :show, xml: @events }
      format.json { render :show, json: @events }
    end
  end
end
