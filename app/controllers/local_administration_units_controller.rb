class LocalAdministrationUnitsController < ApplicationController
  before_action :set_local_administration_unit, only: [
    :show,
    :create_las_admin,
    :create_incomming_email
  ]

  load_and_authorize_resource

  helper_method :collection, :resource, :cache_key_local_administration_units

  def index
    set_index
  end

  def show
    redirect_to local_administration_units_path(id: params[:id])
  end

  def create_las_admin
    @local_administration_unit_admin = @local_administration_unit
      .local_administration_unit_admins
      .build(local_administration_unit_admin_params)

    if @local_administration_unit_admin.save
      redirect_to @local_administration_unit, notice: 'Oprávněný uživatel byl přidán do seznamu.'
    else
      set_index
      if @local_administration_unit_admin.errors[:user]
        @local_administration_unit_admin.errors.add(
          :base,
          'Uživatel se zadaným e-mailem musí existovat'
        )
      end
      render :index
    end
  end

  def create_incomming_email
    @income_email_address = @local_administration_unit
      .income_email_addresses
      .build(income_email_address_params)
    @income_email_address.created_by = current_user

    if @income_email_address.save
      redirect_to @local_administration_unit, notice: 'E-mail byl přidán do seznamu.'
    else
      set_index
      render :index
    end

  end

  private

  def set_index
    set_local_administration_unit
    collection
    cache_key_local_administration_units
    if @local_administration_unit
      @local_administration_unit_admin ||= @local_administration_unit.local_administration_unit_admins.build
      @income_email_address ||= @local_administration_unit.income_email_addresses.build
    end
  end

  def collection
    @collection ||= begin
      if @local_administration_unit
        unsorted_collection = @local_administration_unit.children || LocalAdministrationUnit.none
      else
        unsorted_collection = LocalAdministrationUnit
          .where(ruian_locable_type: 'Vusc')
          .includes(:ruian_locable)
      end

      # Cannot #joins even #order, because ruian could be in another DB
      unsorted_collection.to_a.sort_by { |r| r.ruian_locable.nazev }
    end
  end

  def cache_key_local_administration_units
    @cache_key_local_administration_units ||=  current_user_role_key +
      @local_administration_unit.try(:id).to_s +
      collection.map(&:id).join(':') +
      (Time.now.to_i / 15.minutes).to_s
  end

  def set_local_administration_unit
    @local_administration_unit = params[:id] ?
      LocalAdministrationUnit.find( params[:id]) : nil
  end

  def resource
    @local_administration_unit
  end

  def local_administration_unit_admin_params
    params.require(:local_administration_unit_admin).permit(:email, :role)
  end

  def income_email_address_params
    params.require(:income_email_address).permit(:email, :description)
  end
end
