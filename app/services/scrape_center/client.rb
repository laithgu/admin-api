require "faraday"

module ScrapeCenter
  # HTTP 客户端，用来发请求抓网页
  class Client
    # 伪装浏览器
    USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
      "AppleWebKit/537.36 (KHTML, like Gecko) " \
      "Chrome/126.0.0.0 Safari/537.36"

    def initialize
      @conn = Faraday.new do |f|
        f.adapter :net_http
        f.options.timeout = 10        # 请求超时10秒
        f.options.open_timeout = 10   # 连接超时10秒
        f.headers["User-Agent"] = USER_AGENT

        # 如果设置了代理就用代理
        if ENV["SCRAPE_PROXY"].present?
          f.proxy = ENV["SCRAPE_PROXY"]
        end

        # 如果设置了跳过SSL验证（开发环境用）
        if ENV["SCRAPE_SKIP_SSL"] == "1"
          f.ssl[:verify] = false
        end
      end
    end

    # 发 GET 请求，返回页面 HTML
    def get(url)
      response = @conn.get(url)

      # 如果状态码不是 2xx，就报错
      if !response.success?
        raise "请求失败: HTTP #{response.status} for #{url}"
      end

      # 强制 UTF-8 编码，防止乱码
      response.body.force_encoding("UTF-8")
    end
  end
end
