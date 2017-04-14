class Admin::CategoriesController < Admin::AdminController
  before_action :load_category, only: [:update, :destroy]

  def index
    @categories = Category.all
    @ends = []
    @json = to_node_structure Category.unscoped.first
    @json1 = to_node_food C45.new.root
  end

  def create
    parent = Category.unscoped.find params[:parent_id]
    respont = Category.add params[:name], parent.right
    add_message_flash respont[:type], respont[:messages]
    redirect_to admin_categories_path
  end

  def update
    if @category.update_attributes name: params[:name]
       add_message_flash :success, t(:updated)
    else
      add_message_flash :warning, @category.errors.full_messages
    end
    redirect_to admin_categories_path
  end

  def destroy
    if @deleted = @category.destroy
      add_message_flash :warning, t(:deleted)
    else
      add_message_flash :danger, t(:deleted_fail)
    end
    redirect_to admin_categories_path
  end

  private
  def to_node_structure category
    children = category.children
    if children.any?
      {
        text: {name: category.name, title: "Left: #{category.left}  |  Right: #{category.right}"},
        children: children.map {|child| to_node_structure child}
      }
    else
      {
        text: {name: category.name, title: "Left: #{category.left}  |  Right: #{category.right}"}
      }
    end
  end

  def to_node_food node
    children = node.children
    text = {
      name: node.name,
      title: "foods: #{node.foods.count}",
      desc: "Match: #{node.is_match}"
    }
    text[:desc] = "Gain Ratio: #{node.value}" if node.value != 0
    json = {text: text}
    json[:children] = children.map {|child| to_node_food child} if(children.any?)
    json[:HTMLclass] = "light-gray" unless node.value == 0
    json
  end
  def load_category
    @category = Category.find params[:id]
  end
end
