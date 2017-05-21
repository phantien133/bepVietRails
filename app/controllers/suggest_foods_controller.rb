class SuggestFoodsController < ApplicationController
  def index
    if params[:suggest] && condition_params[:user_conditions_attributes].values.first[:condition_detail_id]
      target_conditions = User.new.user_conditions.build condition_params[:user_conditions_attributes].values
      @foods = Food.suggest(target_conditions, params[:page])
    else
      if user_signed_in?
        @foods = Food.suggest(current_user.user_conditions, params[:page])
      end
    end
    if @foods&.any?
      respond_to do |format|
        format.html
        format.json {render json: @foods.to_json}
      end
    end
  end

  private
  def condition_params
    params.require(:user).permit user_conditions_attributes: [:condition_detail_id]
  end
end
