class Admin::UsersController < Admin::BaseController

    def index
        @users = User.all
    end

    def show
        @user = User.find(params[:id])
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])
        
        if @user.update(user_params)
            redirect_to admin_user_path(@user), notice: "更新完了"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:name, :email_address, :introduction, :is_active)
    end
end
