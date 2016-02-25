class DocumentsController < ApplicationController
  skip_authorization_check only: [:index, :show]

  def index
    @q = Document.ransack(params[:q])
    @collection = @q
      .result
      .accessible_by(current_ability)
      .includes(local_administration_unit: :ruian_locable)
      .page params[:page]
  end

  def show
    @document = Document.includes(
      address_blocks: { events: { shape_with_definition_point: :source } }
    ).accessible_by(current_ability).find(params[:id])
    authorize! :show, @document
  end
end
