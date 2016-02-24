class Event < ActiveRecord::Base
  belongs_to :removed_by, class_name: "User"
  scope :lau_permitted, ->(user) do
    joins(document: :local_administration_unit)
      .joins('LEFT OUTER JOIN local_administration_unit_admins ON local_administration_units.id = local_administration_unit_admins.local_administration_unit_id')
      .where(
        '((documents.published = ?) AND (events.removed_by_id IS NULL))' \
          'OR (local_administration_unit_admins.user_id = ?)',
        true,
        user&.id
      )
  end
end
