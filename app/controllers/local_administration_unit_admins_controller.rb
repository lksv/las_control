class LocalAdministrationUnitAdminsController < ApplicationController
  load_and_authorize_resource :local_administration_unit
  load_and_authorize_resource(
    :local_administration_unit_admin,
    through: :local_administration_unit
  )

  def destroy
    @local_administration_unit_admin.destroy
    redirect_to @local_administration_unit, notice: 'Oprávněný uživatel byl odstraněn.'
  end
end
