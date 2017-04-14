class Admin::IngredientsController < Admin::AdminController
  before_action :load_ingredient, only: [:edit, :update, :destroy]

  def index
    @ingredients = Ingredient.all
    @ingredient = Ingredient.new
  end

  def create
    @ingredient = Ingredient.new ingredient_params
    if @ingredient.save
      add_message_flash :success, t(:created)
    else
      add_message_flash_now :error, t(:failed)
    end
    redirect_to admin_ingredients_path
  end

  def update
    if @ingredient.update_attributes ingredient_params
      add_message_flash :success, t(:updated)
    else
      add_message_flash :error, t(:failed)
    end
    redirect_to admin_ingredients_path
  end

  def destroy
    if @ingredient.destroy
      add_message_flash :success, t(:deleted)
    else
      add_message_flash_now :error, t(:failed)
    end
    redirect_to admin_ingredients_path
  end

  private
  def ingredient_params
    params.require(:ingredient).permit :name, :inscription, :image
  end

  def load_ingredient
    @ingredient = Ingredient.find params[:id]
  end
end