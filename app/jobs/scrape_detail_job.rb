# 抓取单个电影详情页的 Job
class ScrapeDetailJob < ApplicationJob
  queue_as :default

  # 失败重试3次
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  # 数据校验失败就不重试了，直接丢弃
  discard_on ActiveRecord::RecordInvalid

  def perform(detail_url, base_attrs = {})
    # base_attrs 是列表页解析出来的基本信息
    base = base_attrs || {}
    movie = ScrapeCenter::Importer.new.import_movie(detail_url, base)
    Rails.logger.info "已保存: #{movie.name} (id=#{movie.id})"
    movie
  end
end
