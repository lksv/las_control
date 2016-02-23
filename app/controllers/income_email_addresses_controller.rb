class IncomeEmailAddressesController < ApplicationController
  load_and_authorize_resource :local_administration_unit
  load_and_authorize_resource :income_email_address, through: :local_administration_unit

  def destroy
    @income_email_address.destroy
    redirect_to @local_administration_unit, notice: 'E-mail byl odstraněn.'
  end
end
