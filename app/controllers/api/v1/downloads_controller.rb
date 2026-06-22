class Api::V1::DownloadsController < ApplicationController
  before_action :authenticate_user!

  # 获取下载列表
  # GET /api/v1/downloads
  def index
    authorize Download

    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 12).to_i

    # 普通用户只看自己；admin 看全部 —— 由 DownloadPolicy::Scope 决定
    downloads = policy_scope(Download).filter_by(params)
    total     = downloads.count
    records   = downloads.includes(:user).offset((page - 1) * per_page).limit(per_page)

    render json: {
      data: records.as_json(include: {
        user: { only: [:id, :name, :nickname, :email] }
      }),
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

    render json: { data: download }, status: :created
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  # 仅放行 Movie.filter_by 真正用到的字段
  def movie_filter_params
    params.permit(
      :keyword, :director, :actor, :score_min,
      :duration_min, :duration_max, :year, :sort,
      category: [], region: []
    ).to_h
  end
end
