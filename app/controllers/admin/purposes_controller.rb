class Admin::PurposesController < Admin::BaseController

    def index
        @purposes = Purpose.all
        @purpose = Purpose.new
    end

    def create
        @purpose = Purpose.new(purpose_params)

        if @purpose.save
            redirect_to admin_purposes_path, notice: "登録完了"
        else
            @purposes = Purpose.all
            render :index, status: :unprocessable_entity
        end
    end

    def edit
        @purpose = Purpose.find(params[:id])
    end

    def update
        @purpose = Purpose.find(params[:id])

        if @purpose.update(purpose_params)
            redirect_to admin_purposes_path, notice: "更新完了"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @purpose = Purpose.find(params[:id])
        @purpose.destroy
        redirect_to admin_purposes_path, notice: "削除成功"
    end

    private

    def purpose_params
        params.require(:purpose).permit(:name)
    end

end
