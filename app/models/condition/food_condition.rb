class Condition::FoodCondition < TargetCondition
  belongs_to :food
  belongs_to :Condition_detail

  scope :match, -> is_match{where is_match: is_match}
end
