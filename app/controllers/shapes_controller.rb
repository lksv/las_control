class ShapesController < ApplicationController
  load_and_authorize_resource

  def show
    @events = @shape
      .events
      .accessible_by(Ability.new(User.first))
      .includes(:source)
    render layout: false
  end
end
