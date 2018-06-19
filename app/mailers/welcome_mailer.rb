class WelcomeMailer < ActionMailer::Base
  helper :application
  include ApplicationHelper
  default from: "gauravano97@gmail.com"

  # PasswordResetMailer.reset_notify(user).deliver_now
  def add_to_list(user, list)
    subject = 'subscribe'
    @list = list
    @footer = feature('email-footer')
    mail(to: list + '+subscribe@googlegroups.com', subject: subject, from: user.email)
  end

  def welcome_mail(user)
    subject = 'Welcome to Public Lab'
    @user = user
    @footer = feature('email-footer')
    mail(to: user.email, subject: subject, from: "do-not-reply@#{ActionMailer::Base.default_url_options[:host]}")
  end
end
