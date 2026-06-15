class Api::V1::DownloadsController < ApplicationController
  # 获取下载列表
  # GET /api/v1/downloads
  def index
    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 12).to_i

    downloads = Download.filter_by(params)
    # 计算总数
    total = downloads.count
    # 分页
    records = downloads.offset((page - 1) * per_page).limit(per_page)

    render json: {
      data: records,
      meta: { total: total, page: page, per_page: per_page }
    }
  end
end