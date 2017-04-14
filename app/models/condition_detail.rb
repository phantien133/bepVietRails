class ConditionDetail < ApplicationRecord
  has_many :food_conditions, class_name: Condition::FoodCondition.name
  has_many :foods, through: :food_conditions

  belongs_to :condition
end
