class AddressBlocksController < ApplicationController
  load_and_authorize_resource :document
  load_and_authorize_resource :address_block, through: :document

  def show
    @events = @address_block.events.accessible_by(current_ability)
    render layout: false
  end
end
