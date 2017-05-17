class TargetCondition < ApplicationRecord
  belongs_to :condition_detail, dependent: :destroy

  delegate :condition, to: :condition_detail

  scope :is_match, -> is_match do
    where(is_match: is_match)
  end
end
