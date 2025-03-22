class DailyEmailJob < ApplicationJob
  queue_as :default

  def perform
    puts "DailyEmailJob started======#{User.students.inspect}"
    User.students.each do |user|
      puts "Sending email to #{user.email}"
      UserMailer.good_morning_email(user).deliver_now
    end
  end
end
