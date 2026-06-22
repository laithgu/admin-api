class NotificationPolicy < ApplicationPolicy
  # 所有登录用户都能调"我的通知"接口
  def index?
    user.present?
  end

  def unread_count?
    user.present?
  end

  # 只能标记/操作自己的通知
  def update?
    user.present? && record.user_id == user.id
  end

  # def read?
  #   user.present? && record.user_id == user.id
  # end
  # 等价于alias_method :read?, :update?
  alias_method :read?, :update?

  # 批量标记已读 —— 登录就行（policy_scope 已经限制了只能影响自己的）
  def read_all?
    user.present?
  end


  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user
      scope.where(user_id: user.id) # 肯定要加scope，因为通知是针对用户的
    end
  end

end
