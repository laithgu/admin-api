require "caxlsx"

class MovieExporter
  # 导出为 xlsx 文件，返回文件内容
  def self.export(movies)
    # 创建 Excel 文件
    package = Axlsx::Package.new
    sheet = package.workbook.add_worksheet(name: "电影")

    # 写入表头
    sheet.add_row ["名称", "导演", "演员", "分类", "地区", "时长(分钟)", "上映日期", "评分", "剧情简介"]

    # 写入数据行
    movies.find_each do |movie|
      sheet.add_row [
        movie.name,
        movie.director,
        Array(movie.actors).join("、"),
        Array(movie.categories).join("、"),
        Array(movie.regions).join("、"),
        movie.duration,
        movie.published_at.to_s,
        movie.score,
        movie.drama
      ]
    end

    # 返回文件内容
    package.to_stream.read
  end
end
