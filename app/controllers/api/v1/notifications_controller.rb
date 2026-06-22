class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/v1/notifications
  # 当前用户的通知列表，按时间倒序，支持分页
  def index
    authorize Notification

    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 20).to_i

    notifications = policy_scope(Notification).recent
    total = notifications.count
    records = notifications.offset((page - 1) * per_page).limit(per_page)

    render json: {
      data: records,
      meta: { total: total, page: page, per_page: per_page }
    }
  end

  # GET /api/v1/notifications/unread_count
  # 给顶部铃铛小红点用
  def unread_count
    authorize Notification, :unread_count?
    render json: { data: { count: policy_scope(Notification).unread.count } }
  end

  # POST /api/v1/notifications/:id/read
  def read
    notification = Notification.find(params[:id])
    authorize notification, :read?
    notification.read!
    render json: { data: notification }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "通知不存在" }, status: :not_found
  end

  # POST /api/v1/notifications/read_all
  def read_all
    authorize Notification, :read_all?
    policy_scope(Notification).unread.update_all(read_at: Time.current)
    render json: { message: "全部已读" }
  end
end
