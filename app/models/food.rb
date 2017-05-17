class Food < ApplicationRecord

  paginates_per 12

  has_many :food_ingredients, dependent: :destroy
  has_many :ingredients, through: :food_ingredients
  has_many :food_target_conditions, dependent: :destroy
  has_many :food_conditions, through: :food_target_conditions, dependent: :destroy
  has_many :condition_details, through: :food_conditions
  has_many :conditions, through: :condition_details, dependent: :destroy
  has_many :food_hashtags, as: :target, class_name: TargetHashtag.name, dependent: :destroy
  has_many :hashtags, through: :food_hashtags
  has_many :comments, as: :target, dependent: :destroy
  has_many :foods,-> {distinct}, through: :hashtags
  has_many :posts, through: :hashtags
  has_many :activities, as: :target, dependent: :destroy

  validates :name, :cooking_method, :calorie, presence: true

  accepts_nested_attributes_for :food_ingredients,
    reject_if: ->attributes{attributes[:value].blank?}, allow_destroy: true
  accepts_nested_attributes_for :food_hashtags, allow_destroy: true
  accepts_nested_attributes_for :hashtags,
    reject_if: ->attributes{attributes[:name].blank?}
  accepts_nested_attributes_for :food_target_conditions, allow_destroy: true

  mount_uploader :image, PictureUploader

  scope :of_hashtag, ->tag{joins(:hashtags).where(hashtags: {name: tag})}
  scope :name_like, ->keyword do
    join_sql = <<-SQL
      LEFT JOIN target_hashtags ON target_hashtags.target_id = foods.id AND target_hashtags.target_type = 'Food'
      LEFT JOIN hashtags ON hashtags.id = target_hashtags.hashtag_id
    SQL
    joins(join_sql)
      .where("foods.name LIKE ? OR hashtags.name = ?", "%#{keyword}%", keyword) if keyword.present?
  end
  scope :most_rate, -> total do
    join_sql = <<-SQL
      LEFT JOIN rates ON foods.id = rates.rateable_id AND rates.rateable_type = 'Food'
    SQL
    select("foods.*, AVG(rates.stars) AS avg_rate")
      .joins(join_sql)
      .order("avg_rate DESC NULLS LAST")
      .group("foods.id").first(total)
  end

  ratyrate_rateable

  scope :search_by_name, ->keyword { where "name LIKE %?%", keyword }

  def title
    self.name
  end

  class << self
    def suggest target_conditions, page
      return unless target_conditions && target_conditions.any?
      conditions = target_conditions.inject([]){|result, tc| result << c = tc.condition unless result.include? c}.uniq
      c45 = C45.new FoodTargetCondition.all, conditions
      root = [c45.root]
      maps = target_conditions.map {|node| {condition_id: node.condition.id, condition_detail_id: node.condition_detail.id}}.uniq
      not_ids = []
      first_time = maps.size
      while maps.count > 0
        ins = maps.select{|node| node[:condition_id] == root.first.condition.id}
        temple = []
        root.each do |node|
          temple.push *node.children.select{|c| get_match_conditions(ins, c)}
          if first_time == maps.size
            node.children.select{|c| get_not_match_conditions(ins, c)}.each do |n|
              not_ids.push *n.food_target_conditions.map(&:food_id)
            end
          end
        end
        if temple.any?
          root = temple
        else
          break
        end
        root.each_with_index do |node, index|
          root[index] = root[index].children&.first if root[index].children&.first
        end
        ins.each do |i|
          maps.delete i
        end
      end
      ids = []
      root.each do |node|
        ids.push *node.food_target_conditions.map(&:food_id)
      end
      ids = ids.uniq
      ids.each do |i|
        ids.delete(i) if not_ids.include?(i)
      end
      Food.where(id: ids).page(page).per(8)
    end

    private
    def get_match_conditions ins, root_children
      ins.each do |i|
        return true if root_children&.condition.id == i[:condition_detail_id] && root_children&.is_match == true
      end
      return false
    end
    def get_not_match_conditions ins, root_children
      ins.each do |i|
        return true if root_children&.condition.id == i[:condition_detail_id] && root_children&.is_match == false
      end
      return false
    end
  end
end
