FactoryBot.define do
  factory :branch do
    company
    name { Faker::Lorem.word }
  end
end
