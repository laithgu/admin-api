module RedisCenter
  class Client
    CONFIG = Rails.application.config_for(:redis)
    REFRESH_PREFIX = "refresh_token".freeze

    # 进程级共享连接 — 类加载时建立一次
    SHARED_CLIENT = Redis.new(url: CONFIG[:url])

    def initialize
      # 直接复用进程级共享连接，不再每次new一条新连接
      @client = SHARED_CLIENT
    end

    def store_refresh_token(user_id:, jti:, ttl:)
      @client.set(refresh_key(user_id, jti), "1", ex: ttl.to_i)
    end
    def refresh_token_valid?(user_id:, jti:)
      return false if user_id.blank? || jti.blank?
      @client.exists?(refresh_key(user_id, jti))
    end
    def revoke_refresh_token(user_id:, jti:)
      @client.del(refresh_key(user_id, jti))
    end

    private
    def refresh_key(user_id, jti)
      "#{REFRESH_PREFIX}:#{user_id}:#{jti}"
    end
  end
end