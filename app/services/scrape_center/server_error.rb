module ScrapeCenter
  # 5xx 服务端错误（500 / 502 / 503 等）+ 限流（429）
  # 含义：服务端的问题，通常是临时的
  # 处理：retry_on 重试，多半重试就能成功
  class ServerError < StandardError; end
end
