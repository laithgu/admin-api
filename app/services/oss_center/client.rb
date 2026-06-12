require 'aliyun/oss'
# todo 上传的文件可以传oss桶
module OssCenter
  class Client
    client = Aliyun::OSS::Client.new(
      # Endpoint以华东1（杭州）为例，其它Region请按实际情况填写。
      endpoint: 'https://oss-cn-hangzhou.aliyuncs.com',
      # 从环境变量中获取访问凭证。运行本代码示例之前，请确保已设置环境变量OSS_ACCESS_KEY_ID和OSS_ACCESS_KEY_SECRET。
      access_key_id: ENV['OSS_ACCESS_KEY_ID'],
      access_key_secret: ENV['OSS_ACCESS_KEY_SECRET']
    )
  end
end