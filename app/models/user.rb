class User < ActiveRecord::Base
  # NOTE: User can register through UsersController#create (users/simple_create)
  # which do not needs to set password. Password is sended later by email.

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_many :notifications, dependent: :destroy
  has_many :local_administration_unit_admins, dependent: :destroy

  has_many :documents, foreign_key: :created_by_id

  validates :role, inclusion: { :in => Settings.roles, message: 'invalid type of role' }

  validates_acceptance_of :terms_of_service,
    allow_nil: false,
    message: 'musí být potvrzeny',
    on: :create

  after_initialize :default_role

  scope :subscribed, -> {
    where('confirmed_at IS NOT NULL')
      .where('email !~ ?', '^guest_.*example.com')
  }

  attr_accessor :terms_of_service

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
