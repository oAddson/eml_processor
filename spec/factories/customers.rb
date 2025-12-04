FactoryBot.define do
  factory :customer do
    full_name { Faker::Name.name }
    email { Faker::Internet.unique.email(name: full_name) }
    phone { Faker::PhoneNumber.phone_number }
    product_code { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    email_subject { "Interesse no produto #{product_code}" }

    trait :invalid_email do
      email { nil }
    end

    trait :invalid_full_name do
      full_name { "" }
    end

    trait :duplicate_email do
      email { "duplicado@exemplo.com" }
    end
  end
end
