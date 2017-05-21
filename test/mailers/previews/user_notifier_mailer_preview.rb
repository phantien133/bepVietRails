# Preview all emails at http://localhost:3000/rails/mailers/user_notifier_mailer
class UserNotifierMailerPreview < ActionMailer::Preview
  def email_notifier_comment
    UserNotifierMailer.send_email_notifier_comment(User.first, Post.first)
  end
  def email_notifier_registration
    UserNotifierMailer.send_email_registration(User.first)
  end
end
