class Api::V1::DownloadsController < ApplicationController
  include Rails.application.routes.url_helpers   # 用 rails_blob_url 生成下载链接

  before_action :authenticate_user!

  # 获取下载列表
  # GET /api/v1/downloads
  def index
    authorize Download

    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 12).to_i

    # 普通用户只看自己；admin 看全部 —— 由 DownloadPolicy::Scope 决定
    # eager-load file 的 attachment + blob，避免列表渲染时 N+1
    downloads = policy_scope(Download).filter_by(params)
    total     = downloads.count
    records   = downloads
                  .includes(:user, file_attachment: :blob)
                  .offset((page - 1) * per_page)
                  .limit(per_page)

    render json: {
      data: records.map { |d| serialize(d) },
      meta: { total: total, page: page, per_page: per_page }
    }
  end

  # 导出电影使用异步队列，初始化进去的数据只有文件名和pending状态
  # POST /api/v1/downloads
  def create
    authorize Download

    filename = "movies_#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"
    download = Download.create!(name: filename, status: :pending, user: current_user)

    ExportJob.perform_later(download.id, movie_filter_params)

    render json: { data: serialize(download) }, status: :created
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  # 把 Download 序列化成前端要的结构 —— url 现场生成
  # 用 rails_storage_proxy_url：Rails 从 OSS 取文件后代发给浏览器，
  # 避免 OSS 不支持覆盖 response-content-type 导致 400
  def serialize(d)
    d.as_json(
      only: [:id, :name, :status, :created_at, :updated_at, :user_id],
      include: { user: { only: [:id, :name, :nickname, :email] } }
    ).merge(
      url: d.file.attached? ? rails_storage_proxy_url(d.file, disposition: "attachment") : nil
    )
  end

  # 仅放行 Movie.filter_by 真正用到的字段
  def movie_filter_params
    params.permit(
      :keyword, :director, :actor, :score_min,
      :duration_min, :duration_max, :year, :sort,
      category: [], region: []
    ).to_h
  end
end
