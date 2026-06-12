# 抓取列表页的 Job
# 抓到列表后，把每个电影的详情页抓取任务丢到队列里
class ScrapeListJob < ApplicationJob
  queue_as :default

  # 失败重试3次，间隔越来越长
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(page_num)
    client = ScrapeCenter::Client.new
    url    = ScrapeCenter::Importer::LIST_URL_TEMPLATE % page_num
    html   = client.get(url)
    cards  = ScrapeCenter::ListParser.parse(html)

    Rails.logger.info "列表页 #{page_num}，找到 #{cards.size} 部电影"

    # 把每个电影的详情抓取丢到队列里异步执行
    cards.each do |card|
      ScrapeDetailJob.perform_later(card[:detail_url], card)
    end
  end
end
