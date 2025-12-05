class RemoveEmailUniquenessAndNotNullFromCustomers < ActiveRecord::Migration[8.1]
  def change
    remove_index :customers, column: :email, unique: true, if_exists: true

    change_column_null :customers, :email, true
  end
end
