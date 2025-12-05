
FactoryBot.define do
  factory :archived_email do
    transient do
      file_number { rand(1..8) }
      file_name { "email#{file_number}.eml" }
    end

    original_file_name { file_name } # Usa o valor transitório acima
    archive_date { Time.current }

    eml_file do
      file_path = Rails.root.join('spec', 'emails', file_name)

      unless File.exist?(file_path)
        raise "Arquivo de fixture não encontrado: #{file_path}"
      end

      Rack::Test::UploadedFile.new(file_path, 'message/rfc822')
    end

    trait :without_file do
      eml_file { nil }
      after(:build) { |record| record.eml_file.purge if record.eml_file.attached? }
    end
  end
end
