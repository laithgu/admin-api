module ScrapeCenter
  # 导入器：抓取网页数据并保存到数据库
  class Importer
    SOURCE = "ssr1"
    LIST_URL_TEMPLATE = "https://ssr1.scrape.center/page/%d"

    def initialize
      @client = Client.new
    end

    # 导入某一页列表
    def import_page(page_num)
      # 拼接列表页URL
      url = LIST_URL_TEMPLATE % page_num
      html = @client.get(url)

      # 解析列表页，获取每部电影的基本信息和详情页链接
      cards = ListParser.parse(html)

      success = 0
      failed  = 0

      cards.each do |card|
        begin
          # 稍微等一下，别请求太快
          sleep 0.3
          import_movie(card[:detail_url], card)
          success += 1
        rescue => e
          failed += 1
          Rails.logger.error "导入失败 #{card[:detail_url]}: #{e.message}"
        end
      end

      { page: page_num, success: success, failed: failed }
    end

    # 导入单个电影的详情
    def import_movie(detail_url, base_attrs = {})
      # 抓取详情页
      html = @client.get(detail_url)
      detail = DetailParser.parse(html)

      # 合并列表页和详情页的数据
      movie = Movie.find_or_initialize_by(detail_url: detail_url)
      movie.name         = base_attrs[:name]         if base_attrs[:name].present?
      movie.detail_url   = detail_url
      movie.cover_url    = base_attrs[:cover_url]    if base_attrs[:cover_url].present?
      movie.categories   = base_attrs[:categories]   if base_attrs[:categories].present?
      movie.score        = base_attrs[:score]        if base_attrs[:score].present?
      movie.drama        = detail[:drama]
      movie.director     = detail[:directors]&.first
      movie.actors       = detail[:actors]   || []
      movie.regions      = detail[:regions]  || []
      movie.duration     = detail[:duration]
      movie.published_at = detail[:published_at]
      movie.source       = SOURCE
      movie.scraped_at   = Time.current
      movie.save!

      movie
    end
  end
end
