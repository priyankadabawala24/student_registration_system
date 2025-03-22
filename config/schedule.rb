every 1.day, at: '5:00 am' do
    runner "DailyEmailJob.perform_later"
end

every 1.day, at: '5:00 am' do
    runner "BirthdayEmailJob.perform_later"
end