class StudentsController < ApplicationController

  def show
    if current_user.verified?
      @student = current_user
    else
      redirect_to pending_verification_students_path
    end
  end

  def pending_verification
    if current_user.verified?
      redirect_to student_dashboard_path
    else
      flash[:alert] = "Admin will verify your details soon"
    end
  end
end
