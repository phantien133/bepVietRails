class Category < ApplicationRecord
  has_many :foods

  before_destroy :delete_children_category

  validates :name, presence: true

  default_scope {where.not(id: 1).order(left: :asc)}

  class << self
    def add name, parent_right
      return {type: :danger, messages: I18n.t(:blank, name: :name)} unless name.present?
      ActiveRecord::Base.transaction do
        Category.unscoped.where("`categories`.`right` >= ?", parent_right).update_all "`categories`.`right` = `categories`.`right` + 2"
        Category.unscoped.where("`categories`.`left` > ?", parent_right).update_all "`categories`.`left` = `categories`.`left` + 2"
        category = Category.new name: name, left: parent_right,right: parent_right + 1
        if category.save
          return {type: :success, messages: I18n.t(:created)}
        end
      end
      return {type: :danger, messages: I18n.t(:worng)}
    end

    def add! name, parent_right
      ActiveRecord::Base.transaction do
        Category.unscoped.where("`categories`.`right` >= ?", parent_right).update_all "`categories`.`right` = `categories`.`right` + 2"
        Category.unscoped.where("`categories`.`left` > ?", parent_right).update_all "`categories`.`left` = `categories`.`left` + 2"
        category = Category.create! name: name, left: parent_right,right: parent_right + 1
      end
    end
  end

  def children
    Category.where left: (self.left+1)...self.right
  end

  def leaf_node?
    right - left == 1
  end

  private
  def delete_children_category
    width = self.right - self.left + 1
    ActiveRecord::Base.transaction do
      self.children.delete_all
      Category.unscoped.where("`categories`.`right` > ?", self.right).update_all("`categories`.`right` = `categories`.`right` - #{width}")
      Category.unscoped.where("`categories`.`left` > ?", self.right).update_all("`categories`.`left` = `categories`.`left` - #{width}")
    end
  end
end
