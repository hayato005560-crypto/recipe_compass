class RecipesController < ApplicationController
  before_action :reject_guest, only: %i[new create edit update destroy]

  def index
    @recipes = Recipe.all
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Current.user.recipes.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "レシピを投稿しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @recipe = Current.user.recipes.find(params[:id])
  end

  def update
    @recipe = Current.user.recipes.find(params[:id])

    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "レシピを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end 

  def destroy
    @recipe = Current.user.recipes.find(params[:id])
    @recipe.destroy
    redirect_to recipes_path
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :body, :cooking_time, :ingredients, :steps, :image, purpose_ids: [])
  end

  def reject_guest
    if Current.user.is_guest?
      redirect_to recipes_path, alert: "ゲストユーザーはこの操作を行えません"
    end
  end

end
