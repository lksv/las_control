class DocumentsController < ApplicationController
  def index
    @collection = Document.order(:created_at).page params[:page]
    @collection = @collection.includes(local_administration_unit: :ruian_locable)
  end
end
