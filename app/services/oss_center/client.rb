require "aliyun/oss"

# 阿里云 OSS 客户端
module OssCenter
  class Client
    BUCKET_NAME = "laithgu-mp-image"
    def initialize
      # 创建 OSS 客户端
      @client = Aliyun::OSS::Client.new(
        endpoint: "https://oss-cn-hangzhou.aliyuncs.com",
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
      # 返回完整的 URL
      "https://#{BUCKET_NAME}.oss-cn-hangzhou.aliyuncs.com/#{object_key}"
    end

    # 删除文件
    def delete(object_key)
      @bucket.delete_object(object_key)
    end
  end
end
