require "aliyun/oss"

# 阿里云 OSS 客户端
module OssCenter
  class Client
    BUCKET_NAME = "hwb-file"

    def initialize
      # 创建 OSS 客户端
      @client = Aliyun::OSS::Client.new(
        endpoint: "https://oss-cn-beijing.aliyuncs.com",
        access_key_id: ENV["OSS_ACCESS_KEY_ID"],
        access_key_secret: ENV["OSS_ACCESS_KEY_SECRET"]
      )
      # 获取 bucket
      @bucket = @client.get_bucket(BUCKET_NAME)
    end

    # 上传文件
    # file_path: 本地文件路径
    # object_key: 上传后在 OSS 上的路径，比如 "uploads/2026/abc.jpg"
    # 返回：可访问的 URL
    def upload(file_path, object_key)
      @bucket.put_object(object_key, file: file_path)
      "https://#{BUCKET_NAME}.oss-cn-beijing.aliyuncs.com/#{object_key}"
    end

    # 生成临时签名URL（因为我的试用oss创建的bucket是私有的）
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
