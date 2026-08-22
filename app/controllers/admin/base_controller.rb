class Admin::BaseController < ApplicationController
    before_action :require_admin

    private

    def require_admin

        if !Current.user.admin?
            redirect_to root_path
        end
    end
end
