class Api::V1::DownloadsController < ApplicationController
  # 获取下载列表
  # GET /api/v1/downloads
  def index
    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 12).to_i

    downloads = Download.filter_by(params)
    total = downloads.count
    records = downloads.offset((page - 1) * per_page).limit(per_page)

    render json: {
      data: records,
      meta: { total: total, page: page, per_page: per_page }
    }
  end

  # 导出电影使用异步队列，然后初始化进去的数据只有文件名和pending状态
  # POST /api/v1/downloads
  def create
    filename = "movies_#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"
    download = Download.create!(name: filename, status: :pending)

    # 放异步队列
    ExportJob.perform_later(download.id, params.to_unsafe_h)

    render json: { data: download }, status: :created
  # rescue => e
  #   render json: { error: e.message }, status: :internal_server_error
  end
end
