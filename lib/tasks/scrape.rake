namespace :scrape do
  # 开始爬取，默认1到10页
  # 用法: rake scrape:ssr1[1,5]
  task :ssr1, [ :start_page, :end_page ] => :environment do |t, args|
    start_page = (args[:start_page] || 1).to_i
    end_page   = (args[:end_page]   || 10).to_i

    # 检查页数是否合法
    if start_page < 1 || end_page < start_page
      abort "无效的页数: #{start_page}..#{end_page}"
    end

    puts "开始爬取第 #{start_page} 到 #{end_page} 页"

    # 把每一页的爬取任务加到队列里
    (start_page..end_page).each do |page_num|
      ScrapeListJob.perform_later(page_num)
    end

    puts "任务已加入队列，请启动队列消费："
    puts "  SCRAPE_PROXY=http://127.0.0.1:51234 SCRAPE_SKIP_SSL=1 bin/jobs"
    puts ""
    puts "查看进度："
    puts "  rake scrape:progress"
  end

  # 查看爬取进度
  task progress: :environment do
    total_movies = Movie.count
    pending_jobs = SolidQueue::Job.where(finished_at: nil).count
    finished     = SolidQueue::Job.where.not(finished_at: nil).count

    puts "=" * 50
    puts "爬取进度"
    puts "=" * 50
    puts "数据库电影数   : #{total_movies}"
    puts "待执行任务     : #{pending_jobs}"
    puts "已完成任务     : #{finished}"
    puts "=" * 50
  end

  # 清除所有爬取数据和队列
  # 用法: CONFIRM=yes rake scrape:reset
  task reset: :environment do
    if ENV["CONFIRM"] != "yes"
      abort "请用 CONFIRM=yes rake scrape:reset 来确认删除"
    end

    Movie.delete_all
    SolidQueue::Job.delete_all
    SolidQueue::ReadyExecution.delete_all
    puts "清除完毕"
  end
end
