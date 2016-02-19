class CreateLocalAdministrationUnitAdmins < ActiveRecord::Migration
  def change
    create_table :local_administration_unit_admins do |t|
      t.belongs_to :local_administration_unit, index: {
        name: 'las_admins_on_las_id'
      }, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
      t.string :role

      t.timestamps null: false
    end
  end
end
