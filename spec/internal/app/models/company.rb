class Company < ApplicationRecord
  belongs_to :country
  has_many :branches
end
