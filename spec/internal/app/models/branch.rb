class Branch < ApplicationRecord
  belongs_to :company
  belongs_to :category
  has_many :employees
end
