# 导出电影列表到 excel 并上传到 OSS。完成/失败时给用户发通知（DB + WS）。
class ExportJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(download_id, filter_params)
    download = Download.find_by(id: download_id)
    return unless download

    temp_path = nil

    begin
      # 1. 生成 Excel
      movies = Movie.filter_by(filter_params)
      xlsx_data = MovieExporter.export(movies)

      filename = download.name
      temp_path = Rails.root.join("tmp", filename)
      File.binwrite(temp_path, xlsx_data)

      # 2. 上传到 OSS
      object_key = "exports/#{filename}"
      oss_client = OssCenter::Client.new
      oss_client.upload(temp_path.to_s, object_key)

      # 3. 生成签名 URL
      url = oss_client.signed_url(object_key)

      # 4. 更新下载记录为已完成
      download.update!(status: :completed, url: url)

      # 5. 发通知 —— 成功
      notify(download, kind: "download_completed",
             title: "导出完成", body: "#{download.name} 已生成，去下载中心查看")
    rescue => e
      # 失败：先把 download 标记为 failed，通知用户后再让 retry_on 接力重试
      download.update(status: :failed)
      notify(download, kind: "download_failed",
             title: "导出失败", body: "#{download.name} 生成失败：#{e.message}")
      raise   # 抛出去让 retry_on 接住；3 次仍败 → 进 failed_jobs
    ensure
      File.delete(temp_path) if temp_path && File.exist?(temp_path)
    end
  end

  private

  # 写 DB + WebSocket 广播。前端两路兜底：实时弹 toast；刷新页面能看到历史。
  def notify(download, kind:, title:, body:)
    return unless download.user   # 用户被删了就不通知

    notification = Notification.create!(
      user:   download.user,
      kind:   kind,
      title:  title,
      body:   body,
      target: download
    )

    NotificationChannel.broadcast_to(download.user, notification_payload(notification))
  end

  def notification_payload(n)
    {
      id:          n.id,
      kind:        n.kind,
      title:       n.title,
      body:        n.body,
      target_type: n.target_type,
      target_id:   n.target_id,
      read_at:     n.read_at,
      created_at:  n.created_at
    }
  end
end
