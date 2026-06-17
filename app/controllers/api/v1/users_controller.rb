class Api::V1::UsersController < ApplicationController

  # 获取用户列表
  # GET /api/v1/users
  def index
    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    # 用 model 里的筛选方法
    users = User.filter_by(params)

    # 计算总数（在分页之前算）
    total = users.count

    # 分页
    records = users
                .select(:id, :name, :nickname, :avatar, :email, :status, :created_at, :updated_at)
                .offset((page - 1) * per_page)
                .limit(per_page)

    render json: {
      data: records,
      meta: { total: total, page: page, per_page: per_page }
    }
  end

  # 新增用户
  # POST /api/v1/users
  def create
    user = User.create!(user_params)

    render json: { data: user }, status: :created
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private
  def user_params
    params.require(:user).permit(:name, :nickname, :avatar, :email, :password)
  end

end
