class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true
  has_many :likes, as: :target, dependent: :destroy
  has_many :activities, as: :target, dependent: :destroy

  validates :content, presence: true

  after_create :send_notification
  after_create :create_activity

  private
  def create_activity
    Activity.create action_type: :comment, user_id: self.user_id, target: self.target
  end

  def send_notification
    if target.is_a? Post
      users = self.target.commentors
      users.each do |u|
        UserNotifierMailer.send_email_notifier_comment(u, self.target).deliver_now unless u == self.user
      end
      if self.target.is_a?(Post::UserPost) && !users.include?(self.user)
        UserNotifierMailer.send_email_notifier_comment(self.user, self.target).deliver_now
      end
    end
  end
end
