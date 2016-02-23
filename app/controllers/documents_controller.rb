class DocumentsController < ApplicationController
  load_and_authorize_resource

  def index
    @q = Document.ransack(params[:q])
    @collection = @q
      .result
      .accessible_by(current_ability)
      .includes(local_administration_unit: :ruian_locable)
      .page params[:page]
  end
end
