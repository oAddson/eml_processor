class CreateEmailProcessingRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :email_processing_records do |t|
      t.string :processed_file_name
      t.integer :processing_status, null: false, default: 0
      t.jsonb :extracted_data_json
      t.text :error_details
      t.references :archived_email, null: false, foreign_key: true
      t.references :customer, null: true, foreign_key: true

      t.timestamps
    end
  end
end
