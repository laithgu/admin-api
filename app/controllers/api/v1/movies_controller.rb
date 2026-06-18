class Api::V1::MoviesController < ApplicationController
  # 在 show 之前先查找电影，找不到就返回404
  before_action :set_movie, only: [ :show ]

  # 获取电影列表
  # GET /api/v1/movies
  def index
    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    # 用 model 里的筛选方法
    movies = Movie.filter_by(params)

    # 计算总数（在分页之前算）
    total = movies.count

    # 分页
    records = movies
                .select(:id, :name, :cover_url, :score, :categories, :regions, :director, :duration, :published_at)
                .offset((page - 1) * per_page)
                .limit(per_page)

    render json: {
      data: records,
      meta: { total: total, page: page, per_page: per_page }
    }
  end

  # 获取单个电影详情
  # GET /api/v1/movies/:id
  def show
    render json: { data: @movie }
  end

  # 删除电影
  # DELETE /api/v1/movies/:id
  def destroy
    movie = Movie.find(params[:id])
    movie.destroy!
    render json: { message: "删除成功" }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "电影不存在" }, status: :not_found
  end

  private

  # 查找电影，找不到返回404
  def set_movie
    @movie = Movie.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "电影不存在" }, status: :not_found
  end
end
