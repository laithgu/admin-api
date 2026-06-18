# 导出电影列表到excel并上传到oss任务
class ExportJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(download_id, filter_params)
    download = Download.find_by(id: download_id)
    return unless download

    # 1.生成 Excel
    movies = Movie.filter_by(filter_params)
    xlsx_data = MovieExporter.export(movies)

    filename = download.name
    temp_path = Rails.root.join("tmp", filename)
    File.binwrite(temp_path, xlsx_data)

    # 2.上传到OSS
    object_key = "exports/#{filename}"
    oss_client = OssCenter::Client.new
    oss_client.upload(temp_path.to_s, object_key)

    # 3.生成签名URL
    url = oss_client.signed_url(object_key)

    # 4.更新下载记录为已完成
    download.update!(status: :completed, url: url)

  ensure
    # 5. 删除临时文件
    if temp_path && File.exist?(temp_path)
      File.delete(temp_path)
    end
  end

end