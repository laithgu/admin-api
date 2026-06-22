class Api::V1::MoviesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:show, :destroy]

  # 获取电影列表
  # GET /api/v1/movies
  def index
    authorize Movie

    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    # policy_scope 保留 Pundit 链路（未来可在 Scope 里做行级过滤）；filter_by 提供查询条件
    movies = policy_scope(Movie).filter_by(params)
    total  = movies.count

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
    authorize @movie
    render json: { data: @movie }
  end

  # 删除电影
  # DELETE /api/v1/movies/:id
  def destroy
    authorize @movie
    @movie.destroy!
    render json: { message: "删除成功" }
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "电影不存在" }, status: :not_found
  end
end
