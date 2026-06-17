# 基于 PG advisory lock 的分布式锁
module DistributedLock
  # 用法：
  #   DistributedLock.with_lock("scrape_all") do
  #     # 加锁的逻辑
  #   end
  # 如果其他进程已经持有锁，直接返回 false，不阻塞
  # PostgreSQL Advisory Lock 是一种应用级分布式锁，不锁具体数据，而是锁一个自定义 Key。
  # Rails 和 Solid Queue 常用它来避免定时任务、后台任务在多进程或多服务器环境下重复执行。
  # 它比 Redis 分布式锁更简单，因为直接依赖 PostgreSQL 本身
  def self.with_lock(key)
    lock_id = key.hash  # 转成整数
    acquired = ActiveRecord::Base.connection.select_value(
      "SELECT pg_try_advisory_lock(#{lock_id})"
    )

    unless acquired
      Rails.logger.warn "锁 #{key} 已被占用，跳过本次执行"
      return false
    end

    begin
      yield
      true
    ensure
      ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(#{lock_id})")
    end
  end
end
