class MoviePolicy < ApplicationPolicy
  # 登录用户都能看列表 / 详情
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  # 只有 admin 能删
  def destroy?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    # 列表对所有登录用户都一样，不做行级过滤
    def resolve
      scope.all
    end
  end
end
