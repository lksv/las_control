class LocalAdministrationUnitsController < ApplicationController
  before_action :set_local_administration_unit, only: [
    :show,
    :create_las_admin,
    :create_incomming_email,
    :location
  ]

  #load_and_authorize_resource

  helper_method :collection, :resource, :cache_key_local_administration_units

  def index
    set_index
  end

  def options
    authorize! :options, LocalAdministrationUnit
    response = LocalAdministrationUnit.to_sorted_array
    query = params[:query]
    locable_type_query = nil
    locable_type_query = 'Obec' if query.sub!(/^obec\s*/i, '')
    locable_type_query = 'Okres' if query.sub!(/^okres\s*/i, '')
    locable_type_query = 'Momc' if query.sub!(/^M[ČC]\s+|^M[eě]stsk[aá] [cč][aá]st\s*/i, '')
    regexp = /#{Regexp.escape(params[:query])}/i
    response = response.find_all do |object|
      (object[:text] =~ regexp) && (
        locable_type_query.nil? ||
        object[:type] == locable_type_query
      )
    end
    per = params[:per].to_i
    page = params[:page].to_i - 1
    response = response[per * page, per]
    render json: response
  end

  def show
    redirect_to local_administration_units_path(id: params[:id])
  end

  def location
    render json: @local_administration_unit.location.reverse
  end

  def create_las_admin
    @local_administration_unit_admin = @local_administration_unit
      .local_administration_unit_admins
      .build(local_administration_unit_admin_params)

    authorize! :create, @local_administration_unit_admin

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

    authorize! :create, @income_email_address

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
      unsorted_collection.to_a.sort_by { |r| r.lau_nazev }
    end
  end

  def cache_key_local_administration_units
    @cache_key_local_administration_units ||=  current_user_role_key +
      @local_administration_unit.try(:id).to_s +
      collection.map(&:id).join(':') +
      (Time.now.to_i / 5.days).to_s
  end

  def set_local_administration_unit
    @local_administration_unit = params[:id] ?
      LocalAdministrationUnit.find( params[:id]) : nil
    if @local_administration_unit
      authorize! :read, @local_administration_unit
    else
      authorize! :read, LocalAdministrationUnit
    end
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
