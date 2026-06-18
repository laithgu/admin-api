# 阿里云 OSS 客户端
module OssCenter
  class Client
    CONFIG = Rails.application.config_for(:oss)

    # 启动时校验关键配置
    if CONFIG[:access_key_id].blank? || CONFIG[:access_key_secret].blank?
      raise "OSS access keys missing — set OSS_ACCESS_KEY_ID and OSS_ACCESS_KEY_SECRET"
    end

    BUCKET_NAME = CONFIG[:bucket_name]

    # 进程级共享 client / bucket —— 类加载时建立一次
    SHARED_CLIENT = Aliyun::OSS::Client.new(
      endpoint:          CONFIG[:endpoint],
      access_key_id:     CONFIG[:access_key_id],
      access_key_secret: CONFIG[:access_key_secret]
    )
    SHARED_BUCKET = SHARED_CLIENT.get_bucket(BUCKET_NAME)

    def initialize
      # 直接复用进程级共享 bucket，不再每次重新初始化 SDK
      @bucket = SHARED_BUCKET
    end

    # 上传文件
    # file_path: 本地文件路径
    # object_key: 上传后在 OSS 上的路径，比如 "uploads/2026/abc.jpg"
    # 返回：可访问的 URL
    def upload(file_path, object_key)
      @bucket.put_object(object_key, file: file_path)
      "https://#{BUCKET_NAME}.#{URI(CONFIG[:endpoint]).host}/#{object_key}"
    end

    # 生成临时签名 URL（私有 bucket 用）
    # expiry: 有效期，单位秒，默认 1 小时
    def signed_url(object_key, expiry: 3600)
      @bucket.object_url(object_key, true, expiry)
    end

    # 删除文件
    def delete(object_key)
      @bucket.delete_object(object_key)
    end
  end
end
