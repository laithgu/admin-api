class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  # 获取用户列表
  # GET /api/v1/users
  def index
    authorize User

    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    # policy_scope 暂时等价于 User.all，未来在 Scope 里加行级过滤无需改 controller
    users = policy_scope(User).filter_by(params)
    total = users.count

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
    authorize User
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
