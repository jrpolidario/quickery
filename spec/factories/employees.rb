FactoryBot.define do
  factory :employee do
    branch
    name { Faker::Name.name }
  end
end
