class Document < ActiveRecord::Base
  scope :lau_permitted, ->(user, by_time = Time.now) do
    joins(:local_administration_unit)
      .joins('LEFT OUTER JOIN local_administration_unit_admins ON local_administration_units.id = local_administration_unit_admins.local_administration_unit_id')
      .where(
        '(' \
          '(documents.published = ?) AND ' \
          '(documents.pii_public_until IS NULL OR (? < documents.pii_public_until))' \
        ') OR ' \
        '(local_administration_unit_admins.user_id = ?)',
        true,
        by_time,
        user&.id
      )
  end
end
