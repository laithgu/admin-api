# 导出电影列表到 excel 并通过 ActiveStorage 上传到 OSS。
# 完成 / 失败时给用户发通知（DB + WS）。
class ExportJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  EXCEL_CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze

  def perform(download_id, filter_params)
    download = Download.find_by(id: download_id)
    return unless download

    begin
      # 1. 生成 Excel 到内存 —— 不再写本地 tmp 文件
      movies    = Movie.filter_by(filter_params)
      xlsx_data = MovieExporter.export(movies)

      # 2. 通过 ActiveStorage 直接上传到 OSS（StringIO 不落盘）
      download.file.attach(
        io:           StringIO.new(xlsx_data),
        filename:     download.name,
        content_type: EXCEL_CONTENT_TYPE
      )

      # 3. 更新状态
      download.update!(status: :completed)

      # 4. 通知用户成功
      notify(download, kind: "download_completed",
             title: "导出完成", body: "#{download.name} 已生成，去下载中心查看")
    rescue => e
      download.update(status: :failed)
      notify(download, kind: "download_failed",
             title: "导出失败", body: "#{download.name} 生成失败：#{e.message}")
      raise   # 抛出去让 retry_on 接住；3 次仍败 → 进 failed_jobs
    end
  end

  private

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
