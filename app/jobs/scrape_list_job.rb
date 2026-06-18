# 抓取列表页的 Job
# 抓到列表后，把每个电影的详情页抓取任务丢到队列里，并接力下一页。
#
# 错误处理策略：
#   - NotFoundError(404)        —— 页码越界，正常停，不算错
#   - ServerError(5xx / 429)    —— 服务器问题，retry 3 次
#   - Faraday::Error(网络层)    —— 超时/拒连，retry 3 次
#   - ClientError(其它 4xx)     —— 我方问题，不重试，进 failed_jobs 让人查
class ScrapeListJob < ApplicationJob
  queue_as :default

  # 只对"可恢复"错误重试 —— 不再用 StandardError 一锅端
  retry_on ScrapeCenter::ServerError, wait: :polynomially_longer, attempts: 3
  retry_on Faraday::Error,            wait: :polynomially_longer, attempts: 3

  def perform(page_num)
    client = ScrapeCenter::Client.new
    url    = ScrapeCenter::Importer::LIST_URL_TEMPLATE % page_num
    html   = client.get(url)
    cards  = ScrapeCenter::ListParser.parse(html)

    # 空列表 = SPA 站点的"页码越界"信号，正常停
    if cards.empty?
      Rails.logger.info "列表页 #{page_num} 为空，爬取结束"
      return
    end

    Rails.logger.info "列表页 #{page_num}，找到 #{cards.size} 部电影"

    # 详情仍然并行抓
    cards.each do |card|
      ScrapeDetailJob.perform_later(card[:detail_url], card)
    end

    # 列表页接力下一页 —— 串行，能在第一次空页/404 立刻停
    ScrapeListJob.perform_later(page_num + 1)

  rescue ScrapeCenter::NotFoundError
    # 404 = 已经过了最后一页，正常停止，不当作错误，也不重试
    Rails.logger.info "列表页 #{page_num} 返回 404，爬取结束"
  end
end
