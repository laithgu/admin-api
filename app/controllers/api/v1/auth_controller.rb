class Api::V1::AuthController < ApplicationController
  before_action :authenticate_user!, only: [:me, :logout]
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      access_token  = JsonWebToken.encode({ user_id: user.id, type: "access"  }, JsonWebToken::JWT_EXPIRATION_TIME)
      refresh_token = JsonWebToken.encode({ user_id: user.id, type: "refresh" }, JsonWebToken::REFRESH_TOKEN_EXPIRATION_TIME)
      render json: {
        message: "登录成功",
        data: {
          access_token: access_token,
          refresh_token: refresh_token,
          user: user
        }
      }
    else
      render json: { error: "邮箱或密码错误" }, status: :unauthorized
    end
  end
  # 个人信息
  def me
    render json: { data: current_user }
  end

  # 退出登陆。目前没有用到redis,直接返回成功 删除暂时让前端那里删除
  def logout
    render json: { message: "退出成功" }
  end

  def refresh
    result = JsonWebToken.decode(params[:refresh_token])
    return render(json: { error: result[:error] }, status: :unauthorized) unless result[:success]

    payload = result[:payload]
    return render(json: { error: "token类型错误" }, status: :unauthorized) unless payload["type"] == "refresh"

    user = User.find_by(id: payload["user_id"])
    return render(json: { error: "用户不存在" }, status: :unauthorized) unless user

    render json: {
      message: "刷新成功",
      data: {
        access_token: JsonWebToken.encode({ user_id: user.id, type: "access" }, JsonWebToken::JWT_EXPIRATION_TIME)
      }
    }
  end

end
