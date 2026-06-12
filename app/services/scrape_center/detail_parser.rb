require "nokogiri"

module ScrapeCenter
  # 解析电影详情页，提取剧情、导演、演员、地区、时长、上映日期
  class DetailParser
    # 传入 HTML 字符串，返回 hash
    def self.parse(html)
      doc = Nokogiri::HTML(html)

      # 解析剧情简介
      drama_node = doc.at_css(".drama p") || doc.at_css(".drama")
      drama = drama_node&.text&.strip

      # 解析导演
      directors = []
      doc.css(".directors .name").each do |node|
        text = node.text.strip
        directors << text if text.present?
      end

      # 解析演员
      actors = []
      doc.css(".actors .name").each do |node|
        text = node.text.strip
        actors << text if text.present?
      end

      # 解析地区、时长、上映日期（这些信息混在 .info 元素里）
      regions      = []
      duration     = nil
      published_at = nil

      doc.css(".m-v-sm.info").each do |node|
        # 去掉多余空白
        text = node.text.gsub(/\s+/, " ").strip

        if text.include?("上映")
          # 提取日期，格式如 2020-01-01
          date_str = text.match(/\d{4}-\d{2}-\d{2}/)
          published_at = Date.parse(date_str[0]) if date_str
        elsif text.include?("分钟")
          # 格式如 "中国大陆 / 120分钟"
          parts = text.split("/")
          # 第一部分是地区
          if parts[0].present?
            regions = parts[0].split(/[、·\/]/).map(&:strip).select(&:present?)
          end
          # 第二部分是时长，提取数字
          if parts[1].present?
            num = parts[1].match(/(\d+)/)
            duration = num[1].to_i if num
          end
        end
      end

      {
        drama:        drama,
        directors:    directors,
        actors:       actors,
        regions:      regions,
        duration:     duration,
        published_at: published_at
      }
    end
  end
end
