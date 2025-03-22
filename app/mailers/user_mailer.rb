class UserMailer < ApplicationMailer
    default from: "admin@example.com"
  
    def verification_email(user)
      @user = user
      mail(to: @user.email, subject: "Your student account has been verified!")
    end
  
    def registration_email(user, password = nil)
      @user = user
      @password = password
      mail(to: @user.email, subject: "Your student account has been created!")
    end

    def birthday_email(user)
      @user = user
      mail(to: @user.email, subject: "Happy Birthday, #{@user.name}!")
    end

    def good_morning_email(user)
      @user = user
      mail(to: @user.email, subject: "Good Morning, #{@user.name}!")
    end
end
  