class ApplicationController < ActionController::API
  # Pundit 全局启用 —— 控制器里随时可调 authorize / policy_scope
  include Pundit::Authorization

  # 鉴权失败，执行render_forbidden，返回json数据
  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

  def current_user
    @current_user
  end

  private

  def render_forbidden(_e)
    render json: { error: "无权限" }, status: :forbidden
  end

  def authenticate_user!
    Rails.logger.info "Authorization: #{request.headers['Authorization']}"

    token = request.headers["Authorization"]&.split(" ")&.last

    if token.blank?
      render json: { error: "请先登录" }, status: :unauthorized
      return
    end

    result = JsonWebToken.decode(token)

    unless result[:success]
      render json: { error: result[:error] }, status: :unauthorized
      return
    end

    unless result[:payload]["type"] == "access"
      render json: { error: "token类型错误" }, status: :unauthorized
      return
    end

    @current_user = User.find_by(id: result[:payload]["user_id"])

    if @current_user.nil?
      render json: { error: "用户不存在" }, status: :unauthorized
      return
    end

    unless @current_user.active?
      render json: { error: "账号已被禁用" }, status: :forbidden
      return
    end
  end

end
