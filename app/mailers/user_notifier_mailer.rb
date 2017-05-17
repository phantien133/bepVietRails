class UserNotifierMailer < ApplicationMailer
  def send_email_notifier_comment user, post
    @user = user
    @post = post
    mail to: user.email, subject: t("mailer.comment.subject", name: user.name)
  end

  def send_email_registration user
    @user = user
    mail to: user.email, subject: t("mailer.registration", name: user.name)
  end

  def send_email_delete user
    @user = user
    mail to: user.email, subject: t("mailer.delete", name: user.name)
  end

  def sent_email_notifier subject, content
    @content = content
    users = User.where(email: ["phanqtien@gmail.com", "tripletee.3t@gmail.com", "trongttv@gmail.com"])
    users.each do |u|
      mail to: u.email, subject: subject
    end
  end
end
