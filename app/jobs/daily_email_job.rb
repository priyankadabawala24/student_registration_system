class DailyEmailJob < ApplicationJob
  queue_as :default

  def perform
    User.students.each do |user|
      UserMailer.good_morning_email(user).deliver_now
    end
  end
end
