# This class jsut extends LocalAdministrationUnit!
class LocalAdministrationUnit < ActiveRecord::Base
  has_many :income_email_addresses
  has_many :local_administration_unit_admins
end
