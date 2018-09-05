class Company < ApplicationRecord
  belongs_to :country
  belongs_to :category
  has_many :branches
end
