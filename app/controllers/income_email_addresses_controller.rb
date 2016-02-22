class IncomeEmailAddressesController < ApplicationController
  before_action :set_income_email_address, only: [:destroy]
  load_and_authorize_resource

  def destroy
    @income_email_address.destroy
    redirect_to @local_administration_unit, notice: 'E-mail byl odstraněn.'
  end


  private

  def set_income_email_address
    @local_administration_unit = LocalAdministrationUnit.find(
      params[:local_administration_unit_id]
    )
    @income_email_address = @local_administration_unit.income_email_addresses.find(params[:id])
  end
end
