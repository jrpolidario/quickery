class Category < ApplicationRecord
  has_many :employees
  has_many :branches
  has_many :companies
  has_many :countries
end
