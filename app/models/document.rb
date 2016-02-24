class Document < ActiveRecord::Base
  scope :lau_permitted, ->(user) do
    joins(:local_administration_unit)
      .joins('LEFT OUTER JOIN local_administration_unit_admins ON local_administration_units.id = local_administration_unit_admins.local_administration_unit_id')
      .where(
        '(documents.published = ?) ' \
          'OR (local_administration_unit_admins.user_id = ?)',
        true,
        user&.id
      )
  end
end
