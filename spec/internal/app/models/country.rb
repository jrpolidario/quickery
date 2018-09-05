class Country < ApplicationRecord
  belongs_to :category
  has_many :companies
end
