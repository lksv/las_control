class LocalAdministrationUnitAdminsController < ApplicationController
  before_action :set_las, only: [:destroy]
  load_and_authorize_resource

  def destroy
    @local_administration_unit_admin.destroy
    redirect_to @local_administration_unit, notice: 'Oprávněný uživatel byl odstraněn.'
  end


  private

  def set_las
    @local_administration_unit = LocalAdministrationUnit.find(
      params[:local_administration_unit_id]
    )
    @local_administration_unit_admin = @local_administration_unit.local_administration_unit_admins.find(params[:id])
  end
end
