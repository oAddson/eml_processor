FactoryBot.define do
  factory :email_processing_record do
    association :archived_email, factory: :archived_email

    processed_file_name { "#{Faker::Alphanumeric.alphanumeric(number: 10)}.eml" }

    trait :success do
      processing_status { :success }
      association :customer
      extracted_data_json do
        {
          "full_name" => Faker::Name.name,
          "email" => Faker::Internet.email,
          "product_code" => "PROD-#{Faker::Number.number(digits: 4)}"
        }
      end
      error_details { nil }
    end

    trait :failure do
      processing_status { :failure }
      customer { nil }
      extracted_data_json { nil }
      error_details { "Erro de validação: nome do cliente não encontrado no e-mail." }
    end

    trait :pending do
      processing_status { :pending }
      customer { nil }
      extracted_data_json { nil }
      error_details { nil }
    end
  end
end
