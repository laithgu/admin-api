module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # 每个 WS 连接绑定到一个 User —— 后续 channel 里可以直接用 current_user
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # 浏览器 WebSocket 不能自定义 header，token 只能从 URL query 传
    # 例：ws://localhost:3000/cable?token=eyJhbGciOiJIUzI1NiJ9...
    def find_verified_user
      token = request.params[:token]
      reject_unauthorized_connection if token.blank?

      result = JsonWebToken.decode(token)
      reject_unauthorized_connection unless result[:success]

      payload = result[:payload]
      # 只接受 access token，refresh token 不能用来建 WS 连接
      reject_unauthorized_connection unless payload["type"] == "access"

      user = User.find_by(id: payload["user_id"])
      reject_unauthorized_connection if user.nil? || !user.active?

      user
    end
  end

end
