class BirthdayEmailJob < ApplicationJob
  queue_as :default

  def perform
    today = Date.today
    User.students.where("DATE(dob) = ?", today).each do |user|
      UserMailer.birthday_email(user).deliver_now
    end
  end
end
