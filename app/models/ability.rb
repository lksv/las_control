class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      can [:read], Document, Document.lau_permitted(user) do |document|
        by_time = Time.now
        (
          document.published &&
          (document.ppi_public_until.nil? || by_time < document.ppi_public_until)
        ) || (
          user.lau_permitted?(document.local_administration_unit)
        )
      end
      can [:update], User, id: user.id
      can [:read], LocalAdministrationUnit


      # LAU operator and admin can see LocalAdministrationUnitAdmin for its LAU
      can [:read],
        LocalAdministrationUnitAdmin,
        LocalAdministrationUnitAdmin do |las_admin|
          las_admin.user == user
        end
      # LAU admin can change LAU admis for its LAU
      can [:create, :update, :destroy],
        LocalAdministrationUnitAdmin,
        LocalAdministrationUnitAdmin do |las_admin|
          lau = las_admin.local_administration_unit
          lau && lau.local_administration_unit_admins.where(
            user: user,
            role: 'admin'
          ).present?
        end

      # LAU Admin and Operator can change emails for LAU
      can :manage, IncomeEmailAddress do |income_email|
        lau = income_email.local_administration_unit
        lau && lau.local_administration_unit_admins.where(
          user: user
        ).present?
      end

      can [:read], Event, Event.lau_permitted(user) do |event|
        by_time = Time.now
        event.source && (
          (
            event.source.published &&
            (
              event.source.ppi_public_until.nil? ||
              by_time < event.source.ppi_public_until
            ) &&
            event.removed_by_id.nil?
          ) || (
            user.lau_permitted?(event.source.local_administration_unit)
          )
        )
      end
    end
  end
end
