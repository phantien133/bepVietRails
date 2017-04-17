class Food < ApplicationRecord
  belongs_to :category, optional: true

  has_many :food_conditions, foreign_key: :target_id, class_name: Condition::FoodCondition.name
  has_many :condition_details, through: :food_conditions
  has_many :conditions, through: :condition_details
  validates :name, :cooking_method, :calorie, presence: true, allow_nil: true

  scope :match_condition, -> condition_id do
    joins(:food_conditions)
      .where(target_conditions: {condition_detail_id: condition_id, is_match: true}).distinct
  end
  scope :not_match_condition, -> condition_id do
    where.not(id: Food.match_condition(condition_id).map(&:id))
    # joins(:food_conditions)
      # .where(target_conditions: {condition_detail_id: condition_id, is_match: false}).distinct
  end
  scope :is_match, -> is_match do
    joins(:food_conditions).where(target_conditions: {is_match: is_match}).distinct
  end
end
