class Movie < ApplicationRecord
  # 校验规则
  validates :name,       presence: true                                          # 名称必填
  validates :detail_url, presence: true, uniqueness: true,                       # 链接必填且唯一
            format: { with: /\Ahttps?:\/\//i, message: "必须以 http:// 或 https:// 开头" }
  validates :score,      numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 },
            allow_nil: true  # 评分0-10，可以为空

  has_many :comments, dependent: :destroy
  # 根据筛选条件查询电影
  # 用法: Movie.filter_by(params)
  def self.filter_by(params)
    movies = all

    # 按电影名搜索（模糊匹配）
    if params[:keyword].present?
      movies = movies.where("name ILIKE ?", "%#{params[:keyword]}%")
    end

    # 按分类筛选：命中任意一个分类
    if params[:category].present?
      # 去空
      categories = Array(params[:category]).reject(&:blank?)
      movies = movies.where(
        "categories && ARRAY[?]::varchar[]",
        categories
      )
    end

    # 按地区筛选：命中任意一个地区
    if params[:region].present?
      regions = Array(params[:region]).reject(&:blank?)
      movies = movies.where(
      "regions && ARRAY[?]::varchar[]",
      regions
      )
    end

    # 按导演筛选（模糊匹配）
    if params[:director].present?
      movies = movies.where("director ILIKE ?", "%#{params[:director]}%")
    end

    # 按演员筛选
    if params[:actor].present?
      movies = movies.where("? = ANY(actors)", params[:actor])
    end

    # 最低评分
    if params[:score_min].present?
      movies = movies.where("score >= ?", params[:score_min].to_f)
    end

    # 时长范围
    if params[:duration_min].present?
      movies = movies.where("duration >= ?", params[:duration_min].to_i)
    end
    if params[:duration_max].present?
      movies = movies.where("duration <= ?", params[:duration_max].to_i)
    end

    # 按年份筛选
    if params[:year].present?
      movies = movies.where("EXTRACT(YEAR FROM published_at) = ?", params[:year].to_i)
    end

    # 排序
    case params[:sort].to_s
    when "score_desc"
      movies = movies.order(score: :desc, id: :desc)
    when "score_asc"
      movies = movies.order(score: :asc, id: :asc)
    when "published_desc"
      movies = movies.order(published_at: :desc, id: :desc)
    when "published_asc"
      movies = movies.order(published_at: :asc, id: :asc)
    else
      movies = movies.order(id: :desc)  # 默认按最新
    end

    movies
  end
end
