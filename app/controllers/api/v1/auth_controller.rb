class Api::V1::AuthController < ApplicationController
  before_action :authenticate_user!, only: [:me, :logout]

  # POST /api/v1/auth/login
  def login
    user = User.find_by(email: params[:email])
    unless user&.authenticate(params[:password])
      return render json: { error: "邮箱或密码错误" }, status: :unauthorized
    end

    access_token, refresh_token = issue_token_pair(user)

    render json: {
      message: "登录成功",
      data: {
        access_token: access_token,
        refresh_token: refresh_token,
        user: user
      }
    }
  end

  # GET /api/v1/auth/me
  def me
    render json: { data: current_user }
  end

  # POST /api/v1/auth/logout
  def logout
    result = JsonWebToken.decode(params[:refresh_token])
    if result[:success] && result[:payload]["type"] == "refresh"
      RedisCenter::Client.new.revoke_refresh_token(
        user_id: result[:payload]["user_id"],
        jti:     result[:payload]["jti"]
      )
    end
    render json: { message: "退出成功" }
  end

  # POST /api/v1/auth/refresh
  def refresh
    result = JsonWebToken.decode(params[:refresh_token])
    return render(json: { error: result[:error] }, status: :unauthorized) unless result[:success]

    payload = result[:payload]
    return render(json: { error: "token类型错误" }, status: :unauthorized) unless payload["type"] == "refresh"

    redis = RedisCenter::Client.new

    unless redis.refresh_token_valid?(user_id: payload["user_id"], jti: payload["jti"])
      return render(json: { error: "token已失效" }, status: :unauthorized)
    end

    user = User.find_by(id: payload["user_id"])
    return render(json: { error: "用户不存在" }, status: :unauthorized) unless user

    redis.revoke_refresh_token(user_id: user.id, jti: payload["jti"])
    access_token, refresh_token = issue_token_pair(user)

    render json: {
      message: "刷新成功",
      data: {
        access_token: access_token,
        refresh_token: refresh_token
      }
    }
  end

  private
  def issue_token_pair(user)
    refresh_jti = SecureRandom.uuid

    access_token = JsonWebToken.encode(
      { user_id: user.id, type: "access" },
      JsonWebToken::JWT_EXPIRATION_TIME
    )
    refresh_token = JsonWebToken.encode(
      { user_id: user.id, type: "refresh", jti: refresh_jti },
      JsonWebToken::REFRESH_TOKEN_EXPIRATION_TIME
    )

    RedisCenter::Client.new.store_refresh_token(
      user_id: user.id,
      jti: refresh_jti,
      ttl: JsonWebToken::REFRESH_TOKEN_EXPIRATION_TIME.to_i
    )

    [access_token, refresh_token]
  end
end