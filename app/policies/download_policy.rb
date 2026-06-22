class DownloadPolicy < ApplicationPolicy
  # 任何登录用户都能创建导出任务
  def create?
    user.present?
  end

  # 列表本身允许进入，能看到哪些行由 Scope 决定
  def index?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user
      # admin 看全部下载记录；普通用户只看自己的
      return scope.all if user.admin?
      scope.where(user_id: user.id)
    end
  end
end
