class ShapesController < ApplicationController
  load_and_authorize_resource

  caches_page [:by_parcel_stavobj, :public_show], gzip: true

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
        .includes(source: :local_administration_unit)
    end

    respond_to do |format|
      format.html { render layout: false }
      format.xml  { render xml: @events }
      format.json { render json: @events }
    end
  end

  def by_parcel_stavobj
    if params[:stavebni_objekt_id].present?
      @shapes = Shape.where(
        "(source_type = 'Parcela' AND source_id = ?) OR " \
          "(source_type = 'AdresniMisto' and stavebni_objekt_id = ?)",
        params[:parcela_id],
        params[:stavebni_objekt_id]
      )
    else
      @shapes = Shape.where(
        "(source_type = 'Parcela' AND source_id = ?)",
        params[:parcela_id]
      )
    end

    @events = Event
      .where('shape_id IN (?)', @shapes.select(:id))
      .accessible_by(public_ability)
      .includes(source: :local_administration_unit)

    respond_to do |format|
      format.html { render :show, layout: false }
      format.json { render :show, layout: false }
    end
  end

  def public_show
    @events = @shape
      .events
      .accessible_by(public_ability)
      .includes(source: :local_administration_unit)

    respond_to do |format|
      format.html { render :show, layout: false }
      format.json { render :show, layout: false }
    end
  end
end
