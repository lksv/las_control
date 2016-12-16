class AddressBlocksController < ApplicationController
  load_and_authorize_resource :document
  load_and_authorize_resource :address_block, through: :document

  caches_page :show, gzip: true

  def show
    @events = @address_block.events.accessible_by(current_ability)
    respond_to do |format|
      format.html { render layout: false }
      format.xml  { render xml: @events }
      format.json { render json: @events }
    end
  end
end
