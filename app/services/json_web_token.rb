class JsonWebToken

  SECRET_KEY = Rails.application.credentials.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    { success: true, payload: decoded[0] }
  rescue JWT::ExpiredSignature
    { success: false, error: "token已过期" }
  rescue JWT::DecodeError
    { success: false, error: "token无效" }
  end
end