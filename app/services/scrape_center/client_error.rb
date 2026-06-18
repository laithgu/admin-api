module ScrapeCenter
  # 4xx 中除 404 之外的客户端错误（400 / 403 等）
  # 含义：是"我们这边的问题"（请求写错 / 被封 / 鉴权失败）—— 重试不会变成功
  # 处理：不重试，让 Job 失败，进 failed_jobs 让人查
  class ClientError < StandardError; end
end
