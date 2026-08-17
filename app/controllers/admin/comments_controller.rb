class Admin::CommentsController < Admin::BaseController

    def index
        @recipe = Recipe.find(params[:recipe_id])
        @comments = @recipe.comments
    end

    def destroy
        @recipe = Recipe.find(params[:recipe_id])
        @comment = @recipe.comments.find(params[:id])

        @comment.destroy
        redirect_to admin_recipe_comments_path(@recipe), notice: "コメントを削除しました。"
    end
end