require "nokogiri"

module ScrapeCenter
  # 解析电影列表页，提取每部电影的基本信息
  class ListParser
    BASE_URL = "https://ssr1.scrape.center"

    # 传入 HTML 字符串，返回电影数组
    # 每个元素是一个 hash: { name:, detail_url:, cover_url:, categories:, score: }
    def self.parse(html)
      doc = Nokogiri::HTML(html)
      results = []

      # 每部电影是一个 .item 元素
      doc.css(".item").each do |card|
        begin
          # 获取详情页链接
          href = card.at_css(".name")&.attr("href")
          next if href.blank?

          # 获取分类（可能多个）
          categories = []
          card.css(".el-button span").each do |span|
            text = span.text.strip
            categories << text if text.present?
          end

          results << {
            name:       card.at_css("h2")&.text&.strip,
            detail_url: "#{BASE_URL}#{href}",
            cover_url:  card.at_css(".cover")&.attr("src"),
            categories: categories,
            score:      card.at_css(".score")&.text&.strip&.to_f
          }
        rescue => e
          # 解析某一条失败了就跳过，不影响其他的
          Rails.logger.warn "解析列表卡片失败: #{e.message}"
        end
      end

      results
    end
  end
end
