class User < ApplicationRecord
  # has_secure_password 的作用：
  #
  # 1. 提供 password 虚拟字段
  # 2. 自动把密码哈希后存入 password_digest
  # 3. 提供 authenticate 方法验证密码
  # 4. 防止数据库保存明文密码
  has_secure_password

  enum :status, { active: 0, disabled: 1 }
  enum :role, { user: 0, admin: 1 }

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.filter_by(params)
    users = all

    # 姓名模糊搜索
    if params[:name].present?
      users = users.where("name ILIKE ?" ,"%#{params[:name]}%")
    end

    if params[:nickname].present?
      users = users.where("nickname ILIKE ?" ,"%#{params[:nickname]}%")
    end

    if params[:email].present?
      users = users.where("email ILIKE ?" ,"%#{params[:email]}%")
    end

    if params[:start_date].present?
      users = users.where("created_at >= ?" , "#{params[:start_date]}")
    end
    if params[:end_date].present?
      users = users.where("created_at <= ?" , "#{params[:end_date]}")
    end

    users.order(id: :desc)
  end
end
