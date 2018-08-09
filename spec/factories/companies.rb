FactoryBot.define do
  factory :company do
    country
    name { Faker::Company.name }
  end
end
