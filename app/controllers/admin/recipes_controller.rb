class Admin::RecipesController < Admin::BaseController

    def index
        @recipes = Recipe.all
    end

    def show
        @recipe = Recipe.find(params[:id])
    end

    def destroy
        @recipe = Recipe.find(params[:id])
        @recipe.destroy
        redirect_to admin_recipes_path, notice: "削除しました"
    end
end