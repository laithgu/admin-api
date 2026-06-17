class ScrapeAllJob < ApplicationJob
  queue_as :default

  def perform(start_page = 1, end_page = 10, clear_existing: false)
    DistributedLock.with_lock("scrape_all_job") do
      if clear_existing
        Rails.logger.info "清除存量电影数据..."
        Comment.delete_all   # 先删评论
        Movie.delete_all     # 再删电影
      end

      Rails.logger.info "定时爬取第 #{start_page} 到 #{end_page} 页"

      (start_page..end_page).each do |page_num|
        ScrapeListJob.perform_later(page_num)
      end
    end
  end
end
