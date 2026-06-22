class Notification < ApplicationRecord
  belongs_to :user
  # 肯能关联多种对象（target_type + target_id 两个字段记录"指向谁"）
  # 可能是下载通知，评论通知，点赞通知等
  belongs_to :target, polymorphic: true, optional: true

  validates :kind, :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read!
    update!(read_at: Time.current) if read_at.nil?
  end

  def read?
    read_at.present?
  end
end
