class CommentsController < ApplicationController
    before_action :reject_guest, only: %i[create edit update destroy]

    def create
        @recipe = Recipe.find(params[:recipe_id])
        @comment = @recipe.comments.build(comment_params)
        @comment.user = Current.user

        if @comment.save
          redirect_to recipe_path(@recipe)
        else
          @comments = @recipe.comments.where.not(id: nil)
          render "recipes/show", status: :unprocessable_entity
        end
    end

    def edit
        @recipe = Recipe.find(params[:recipe_id])
        @comment = @recipe.comments.find(params[:id])

        if Current.user != @comment.user
            redirect_to recipe_path(@recipe), alert: "自分のコメントのみ編集できます"
        end
    end

    def update
        @recipe = Recipe.find(params[:recipe_id])
        @comment = @recipe.comments.find(params[:id])

        return redirect_to recipe_path(@recipe), alert: "自分のコメントのみ更新できます" if Current.user != @comment.user

        if @comment.update(comment_params)
            redirect_to recipe_path(@recipe), notice: "更新完了"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @recipe = Recipe.find(params[:recipe_id])
        @comment = @recipe.comments.find(params[:id])

        if Current.user == @comment.user
            @comment.destroy
            redirect_to recipe_path(@recipe)
        else
            redirect_to recipe_path(@recipe), alert: "自分のコメントのみ削除できます"
        end
    end

    private
    
    def comment_params
        params.require(:comment).permit(:body)
    end

end
