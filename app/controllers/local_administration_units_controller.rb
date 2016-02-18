class LocalAdministrationUnitsController < ApplicationController
  def index
    parent_id = params[:parent]
    @parent = parent_id ? LocalAdministrationUnit.find(parent_id) : nil
    if @parent
      @collection = @parent.children || LocalAdministrationUnit.none
    else
      @collection = LocalAdministrationUnit
        .where(ruian_locable_type: 'Vusc')
        .includes(:ruian_locable)
    end


    # Cannot #joins even #order, because ruian could be in another DB
    @sorted_collection = @collection.to_a.sort_by { |r| r.ruian_locable.nazev }
  end
end
