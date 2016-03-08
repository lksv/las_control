class DocumentsController < ApplicationController
  skip_authorization_check only: [:index, :show]

  def index
    @q = Document.ransack(params[:q])
    @q.sorts = 'from_date desc' if @q.sorts.empty?
    @collection = @q
      .result
      .accessible_by(current_ability)
      .includes(local_administration_unit: :ruian_locable)
      .page params[:page]

    lau_filter = params[:q] ? params[:q][:local_administration_unit_id_eq] : nil
    @local_administration_unit =
      LocalAdministrationUnit.find_by(id: lau_filter) ||
      LocalAdministrationUnit.new
  end

  def show
    @document = Document.includes(
      address_blocks: { events: { shape_with_definition_point: :source } }
    ).accessible_by(current_ability).find(params[:id])
    authorize! :show, @document
  end
end
