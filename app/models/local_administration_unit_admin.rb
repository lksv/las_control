class LocalAdministrationUnitAdmin < ActiveRecord::Base
  belongs_to :local_administration_unit
  belongs_to :user

  validates   :role, inclusion: {
    :in => Settings.las_roles,
    message: 'invalid LAS role type'
  }
  validates :user, presence: true
  validates :user, uniqueness: { scope: :local_administration_unit_id }

  after_initialize :default_role

  def self.by_user(user)
    where(user_id: user)
  end

  def self.by_admin_user(user)
    where(
      role: 'admin',
      user_id: user
    )
  end


  def default_role
    self.role = 'admin' if role.blank?
  end

  def email
    user&.email
  end

  def email=(email)
    self.user = User.find_by(email: email)
  end
end
