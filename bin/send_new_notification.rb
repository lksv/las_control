#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

Rails.logger = Logger.new(STDERR)
Rails.logger.level = Logger::DEBUG

#User
#  .find_by(email: 'lukas.svoboda@gmail.com')
#  .notifications
#  .update_all(last_send_by_mail: 60.days.ago)

#User.where(email: 'lukas.svoboda@gmail.com').each do |user|
User.all.each do |user|
  begin
    last_send_by_mail = Time.now
    UserMailer.new_events(user).deliver_now
    user.notifications.update_all(last_send_by_mail: last_send_by_mail)
  rescue => err
    Rails.logger.error "Cannot deliver notification to #{user.email}: #{err}"
    Rails.logger.error err.backtrace.join("\n")
  end
end
