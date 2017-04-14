class Condition < ApplicationRecord
  has_many :condition_details
  has_many :food, through: :condition_details
end
