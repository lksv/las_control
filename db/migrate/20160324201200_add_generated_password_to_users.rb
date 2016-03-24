class AddGeneratedPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :generated_password, :string
  end
end
