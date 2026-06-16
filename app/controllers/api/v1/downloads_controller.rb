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

  # 导出电影 Excel 并上传到 OSS，保存下载记录
  # POST /api/v1/downloads
  def create
    # 1. 生成 Excel 文件（先写到临时文件）
    movies = Movie.filter_by(params)
    xlsx_data = MovieExporter.export(movies)

    filename = "movies_#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"
    temp_path = Rails.root.join("tmp", filename)
    File.binwrite(temp_path, xlsx_data)

    # 2. 上传到 OSS
    object_key = "exports/#{filename}"
    oss_client = OssCenter::Client.new
    oss_client.upload(temp_path.to_s, object_key)

    # 3. 生成签名 URL（因为 bucket 是私有的）
    url = oss_client.signed_url(object_key)

    # 4. 保存下载记录到数据库
    download = Download.create!(name: filename, url: url)

    # 5. 删除临时文件
    File.delete(temp_path)

    render json: { data: download }, status: :created
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
