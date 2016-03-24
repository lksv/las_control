class User < ActiveRecord::Base
  # NOTE: User can register through UsersController#create (users/simple_create)
  # which do not needs to set password. Password is sended later by email.

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_many :notifications, dependent: :destroy
  has_many :local_administration_unit_admins, dependent: :destroy

  validates :role, inclusion: { :in => Settings.roles, message: 'invalid type of role' }
  after_initialize :default_role

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def admin?
    role == 'admin'
  end

  def lau_role(lau)
    return nil if lau.nil?
    lau_admin = lau.local_administration_unit_admins.where(
      user: self
    ).first
    lau_admin && lau_admin.role
  end

  def lau_admin?(lau)
    lau_role(lau) == 'admin'
  end

  def lau_operator?(lau)
    lau_role(lau) == 'operator'
  end

  def lau_permitted?(lau)
    lau_role(lau).in? %w(admin operator)
  end

  private

  def default_role
    self.role = 'public' if role.blank?
  end
end
