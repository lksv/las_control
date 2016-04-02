class UserMailer < ActionMailer::Base
  default from: ENV['SMTP_SENDER']
  helper EventsHelper

  def new_events(user)
    ability = Ability.new(user)
    @show_max = 30
    @user = user
    @events_by_notification = user.notifications.inject({}) do |res, notification|
      ne = Event.where(id: notification.new_events.not_lau)
        .accessible_by(ability)
        .includes(:address_block, :source)
      res[notification] = ne if ne.present?
      res
    end
    @events = @events_by_notification.values.flatten.uniq
    Rails.logger.info "#{user.email}: Sending #{@events.size} events."
    return nil if @events.blank?

    mail(
      to: user.email,
      subject: 'Novinky z Vaší sledované oblasti'
    )
  end
end
