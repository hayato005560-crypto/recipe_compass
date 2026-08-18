class RatingsController < ApplicationController
  before_action :reject_guest

  def create
    @recipe = Recipe.find(params[:recipe_id])

    if @recipe.user == Current.user
      return redirect_to recipe_path(@recipe),
                         alert: "自分のレシピは評価できません。"
    end

    @rating = @recipe.ratings.build(rating_params)
    @rating.user = Current.user

    if @rating.save
      redirect_to recipe_path(@recipe), notice: "評価しました。"
    else
      redirect_to recipe_path(@recipe), alert: "評価に失敗しました。"
    end
  end

  def update
    @recipe = Recipe.find(params[:recipe_id])

    if @recipe.user == Current.user
      return redirect_to recipe_path(@recipe),
                         alert: "自分のレシピは評価できません。"
    end

    @rating = @recipe.ratings.find_by!(user: Current.user)

    if @rating.update(rating_params)
      redirect_to recipe_path(@recipe), notice: "評価を更新しました。"
    else
      redirect_to recipe_path(@recipe),
                  alert: "評価の更新に失敗しました。"
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score)
  end
end