class UserPolicy < ApplicationPolicy
  # 用户列表和创建用户都是后台管理操作，只允许admin
  def index?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
