class JsonWebToken
  SECRET_KEY = Rails.application.credentials.secret_key_base

  CONFIG = Rails.application.config_for(:jwt)
  JWT_EXPIRATION_TIME = CONFIG[:access_token_expires_in].seconds
  REFRESH_TOKEN_EXPIRATION_TIME = CONFIG[:refresh_token_expires_in].seconds

  def self.encode(payload, exp = JWT_EXPIRATION_TIME)
    payload[:exp] = exp.from_now.to_i
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