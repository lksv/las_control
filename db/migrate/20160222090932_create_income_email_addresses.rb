class CreateIncomeEmailAddresses < ActiveRecord::Migration
  def change
    create_table :income_email_addresses do |t|
      t.string        :email,                     null: false
      t.integer       :created_by_id,             null: false
      t.belongs_to    :local_administration_unit, index: true, foreign_key: true
      t.text          :description

      t.timestamps null: false
    end
  end
end
