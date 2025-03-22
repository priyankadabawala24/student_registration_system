class ApplicationController < ActionController::Base
    before_action :authenticate_user!

    def after_sign_in_path_for(resource)
        if resource.admin?
          admin_root_path # Redirect admins to ActiveAdmin dashboard
        else
          student_dashboard_path # Redirect students to their dashboard
        end
    end
end
