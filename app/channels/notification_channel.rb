class NotificationChannel < ApplicationCable::Channel
  # 客户端 subscribe 时调用
  # 用 stream_for current_user —— Rails 内部生成一个跟 user 绑定的唯一 stream 名
  # 后端只要 NotificationChannel.broadcast_to(user, payload)，就只有该 user 的连接能收到
  def subscribed
    stream_for current_user
    Rails.logger.info "[NotificationChannel] User##{current_user.id} subscribed"
  end

  def unsubscribed
    Rails.logger.info "[NotificationChannel] User##{current_user.id} unsubscribed"
  end
end
