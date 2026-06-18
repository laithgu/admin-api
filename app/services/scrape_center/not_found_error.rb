module ScrapeCenter
  # 404 —— 页码越界 / 资源不存在。调用方按"正常结束"处理，不重试
  class NotFoundError < StandardError; end
end
