namespace :scrape do
  SCRAPE_JOB_CLASSES = %w[ScrapeListJob ScrapeDetailJob ScrapeAllJob].freeze

  # 开始爬取，从某页开始，自动接力到没数据为止
  # 用法:
  #   rake scrape:ssr1         # 从第 1 页开始
  #   rake scrape:ssr1[3]      # 从第 3 页开始
  task :ssr1, [ :start_page ] => :environment do |_t, args|
    start_page = (args[:start_page] || 1).to_i

    if start_page < 1
      abort "无效的起始页数: #{start_page}"
    end

    puts "开始爬取，从第 #{start_page} 页起，自动跑到没数据为止"
    ScrapeListJob.perform_later(start_page)

    puts ""
    puts "请确保队列已启动："
    puts "  SCRAPE_PROXY=http://127.0.0.1:51234 SCRAPE_SKIP_SSL=1 bin/jobs"
    puts "查看进度："
    puts "  rake scrape:progress"
  end

  # 查看爬取进度
  task progress: :environment do
    total_movies = Movie.count
    scrape_jobs  = SolidQueue::Job.where(class_name: SCRAPE_JOB_CLASSES)
    pending_jobs = scrape_jobs.where(finished_at: nil).count
    finished     = scrape_jobs.where.not(finished_at: nil).count

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
    scrape_job_ids = SolidQueue::Job.where(class_name: SCRAPE_JOB_CLASSES).pluck(:id)
    SolidQueue::ReadyExecution.where(job_id: scrape_job_ids).delete_all
    SolidQueue::Job.where(id: scrape_job_ids).delete_all

    puts "爬虫任务清除完毕"
  end
end
