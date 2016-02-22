class IncomeEmailAddress < ActiveRecord::Base
  belongs_to :local_administration_unit
  belongs_to :created_by, class_name: 'User'
  validates :email, :created_by, :local_administration_unit, presence: true
  validates :email, uniqueness: true
end
