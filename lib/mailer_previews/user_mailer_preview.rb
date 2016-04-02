class UserMailerPreview < ActionMailer::Preview
  def new_events
    UserMailer.new_events(User.find_by(email: 'lukas.svoboda@gmail.com'))
  end
end
