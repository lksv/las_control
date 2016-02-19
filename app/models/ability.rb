class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      can [:read], Document # TODO, published: true
      can [:update], User, id: user.id
      can [:read], LocalAdministrationUnit

      # LAU_admin can change domanis and emails for LAU
      can [:update], LocalAdministrationUnit do |lau|
        # Using another SQL search to keep the DBs separate
        LocalAdministrationUnitAdmin.find_by(
          local_administration_unit_id: lau,
          role: 'admin'
        )
      end

      # LAU operator and admin can see LocalAdministrationUnitAdmin for its LAU
      can [:read],
        LocalAdministrationUnitAdmin,
        LocalAdministrationUnitAdmin.by_user(user) do
          true
        end
      # LAU admin can change LAU admis for its LAU
      can [:update],
        LocalAdministrationUnitAdmin,
        LocalAdministrationUnitAdmin.by_admin_user(user)
    end
  end
end
