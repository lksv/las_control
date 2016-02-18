class DocumentsController < ApplicationController
  def index
    @q = Document.ransack(params[:q])
    @collection = @q
      .result
      .includes(local_administration_unit: :ruian_locable)
      .page params[:page]
  end
end
