class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_many :local_administration_unit_admins

  validates   :role, :inclusion => { :in => Settings.roles, message: 'invalid type of role' }
  after_initialize :default_role


  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def admin?
    role == 'admin'
  end

  def lau_role(lau)
    lau = local_administration_unit_admins.find(lau)
    lau && lau.role
  end

  def lau_admin?(lau)
    lau_role(lau) == 'admin'
  end

  def lau_operator?(lau)
    lau_role(lau) == 'operator'
  end


  private

  def default_role
    self.role = 'public' if role.blank?
  end
end
