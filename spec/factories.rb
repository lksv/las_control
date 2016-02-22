FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password "A12345678"
    password_confirmation { password }
  end

  factory :local_administration_unit do
    ruian_locable_type 'Obec'
    ruian_locable_id   582786 # Brno
    initialize_with do
      LocalAdministrationUnit.find_or_create_by(ruian_locable_id: 582786)
    end
  end

  factory :local_administration_unit_admin do
    local_administration_unit
    user
  end

  factory :income_email_address do
    sequence(:email) { |n| "income#{n}@example.com" }
    local_administration_unit
    association :created_by, factory: :user
  end

end
