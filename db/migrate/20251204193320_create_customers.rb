class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :product_code
      t.string :email_subject

      t.timestamps
    end

    add_index :customers, :email, unique: true
  end
end
