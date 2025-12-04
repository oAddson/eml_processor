class CreateArchivedEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :archived_emails do |t|
      t.string :original_file_name
      t.datetime :archive_date

      t.timestamps
    end
  end
end
