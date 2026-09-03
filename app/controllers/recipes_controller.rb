class RecipesController < ApplicationController
  before_action :reject_guest, only: %i[new create edit update destroy]

  def index
    keyword = params[:keyword]
    target = params[:target]
    @purposes = Purpose.all
    purpose_id = params[:purpose_id]
    @recipes = Recipe.all
    sort = params[:sort]

    @food_labels = params[:food_labels]

    if @food_labels.present?
      image_search_recipes = Recipe.none

      @food_labels.each do |label|
        image_search_recipes = image_search_recipes.or(
          Recipe.where("ingredients LIKE ?", "%#{label}%")
        )
      end

      @recipes = image_search_recipes
    end

    if keyword.present?
      case target
        when "title"
          @recipes = @recipes.where("title LIKE ?", "%#{keyword}%")
        when "body"
          @recipes = @recipes.where("body LIKE ?", "%#{keyword}%")
        when "ingredients"
          @recipes = @recipes.where("ingredients LIKE ?", "%#{keyword}%")
        when "steps"
          @recipes = @recipes.where("steps LIKE ?", "%#{keyword}%")
        when "all"
          @recipes = @recipes.where(
            "title LIKE ? OR body LIKE ? OR ingredients LIKE ? OR steps LIKE ?",
                "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%"
          )
      end
    end

    if purpose_id.present?
      @recipes = @recipes.joins(:purposes).where( purposes: { id: purpose_id } )
    end

    case sort
      when "newest"
        @recipes = @recipes.order(created_at: :desc)
      when "oldest"
        @recipes = @recipes.order(created_at: :asc)
      when "high_rating"
        @recipes = @recipes.left_joins(:ratings).group("recipes.id").order("AVG(ratings.score) DESC")
      else
        @recipes = @recipes.order(created_at: :asc)
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
    @comments = @recipe.comments

    if Current.user.present? &&
       !Current.user.is_guest? &&
       Current.user != @recipe.user

      @rating = @recipe.ratings.find_or_initialize_by(user: Current.user)
    end
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
    redirect_to recipes_path, notice: "レシピを削除しました。"
  end

  def image_search
    image = params[:image]

    unless image.present?
      redirect_to recipes_path, alert: "画像を選択してください。"
      return
    end

    food_labels = VisionService.new.analyze(image)

    redirect_to recipes_path(food_labels: food_labels)
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :body, :cooking_time, :ingredients, :steps, :image, purpose_ids: [])
  end

end
