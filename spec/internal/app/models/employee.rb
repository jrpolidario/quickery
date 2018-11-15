class Employee < ApplicationRecord
  belongs_to :branch
  belongs_to :category
  belongs_to :country, foreign_key: :branch_company_country_id

  quickery(
    branch: {
      company: {
        country: {
          name: :branch_company_country_name,
        }
      }
    }
  )

  quickery(
    branch: {
      company: {
        country: {
          id: :branch_company_country_id
        },
        name: :branch_company_name
      }
    }
  )

  def self.quickery_before_create_or_update(employee, new_values)
    employee.assign_attributes(new_values)
  end

  def self.quickery_before_association_update(employees, record_to_be_updated, new_values)
    employees.update_all(new_values)
  end

  def self.quickery_before_association_destroy(employees, record_to_be_destroyed, new_values)
    employees.update_all(new_values)
  end
end
