class Category < ApplicationRecord

  before_destroy :delete_children_category

  validates :name, presence: true

  has_many :tips, foreign_key: :target_id, dependent: :destroy, class_name: Post::Tip.name


  default_scope {where.not(id: 1).order(left: :asc)}

  scope :name_like, -> keyword { where("name LIKE ?", "%#{keyword}%") if keyword.present?}

  scope :leafs, -> { where("categories.right - categories.left = 1") }

  class << self
    def add name, parent_right, parent_level
      return {type: :danger, messages: I18n.t(:blank, name: :name)} unless name.present?
      ActiveRecord::Base.transaction do
        Category.unscoped.where('"categories"."right" >= ?', parent_right).update_all '"right" = "right" + 2'
        Category.unscoped.where('"categories"."left" > ?', parent_right).update_all '"left" = "left" + 2'
        category = Category.new name: name, left: parent_right,right: parent_right + 1, level: parent_level + 1
        if category.save
          return {type: :success, messages: I18n.t(:created)}
        end
      end
      return {type: :danger, messages: I18n.t(:worng)}
    end

    def add! name, parent_right, parent_level
      ActiveRecord::Base.transaction do
        Category.unscoped.where('"categories"."right" >= ?', parent_right).update_all '"right" = "right" + 2'
        Category.unscoped.where('"categories"."left" > ?', parent_right).update_all '"left" = "left" + 2'
        category = Category.create! name: name, left: parent_right,right: parent_right + 1, level: parent_level + 1
      end
    end

    def base_category
      Category.unscoped.first
    end
  end

  def children
    Category.where left: (self.left+1)...self.right
  end

  def instance_children
    children.where level: self.level + 1
  end

  def leaf_node?
    right - left == 1
  end

  private
  def delete_children_category
    width = self.right - self.left + 1
    ActiveRecord::Base.transaction do
      self.children.delete_all
      Category.unscoped.where('"categories"."right" > ?', self.right).update_all('"right" = "right" - #{width}')
      Category.unscoped.where('"categories"."left" > ?', self.right).update_all('"left" = "left" - #{width}')
    end
  end
end
