class Event < ActiveRecord::Base
  belongs_to :removed_by, class_name: "User"
  scope :lau_permitted, ->(user, by_time = Time.now) do
    joins(document: :local_administration_unit)
      .joins('LEFT OUTER JOIN local_administration_unit_admins ON local_administration_units.id = local_administration_unit_admins.local_administration_unit_id')
      .where(
        '(' \
          '(documents.published = ?) AND ' \
          '((documents.ppi_public_until IS NULL) OR (? < documents.ppi_public_until)) AND ' \
          '(events.removed_by_id IS NULL)' \
        ') OR (local_administration_unit_admins.user_id = ?)',
        true,
        by_time,
        user&.id
      )
  end
end
