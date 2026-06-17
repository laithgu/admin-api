class Api::V1::AuthController < ApplicationController
  before_action :authenticate_user!, only: [:me, :logout]
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        message: "登录成功",
        data: {
          token: token,
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

end
