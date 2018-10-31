class Employee < ApplicationRecord
  belongs_to :branch
  belongs_to :category
  belongs_to :country, foreign_key: :branch_company_country_id

  # quickery do
  #   branch.company.country.name == :branch_company_country_name
  #   branch.company.country.id == :branch_company_country_id
  # end

  quickery(
    branch: {
      company: {
        country: {
          name: :branch_company_country_name,
          # id: :branch_company_country_id
        },
        # name: :branch_company_name
      }
    }
  )

  quickery(
    branch: {
      company: {
        country: {
          # name: :branch_company_country_name,
          id: :branch_company_country_id
        },
        name: :branch_company_name
      }
    }
  )
end
