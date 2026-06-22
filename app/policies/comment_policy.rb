class CommentPolicy < ApplicationPolicy
  # 父类 ApplicationPolicy 已经处理好 user / record 注入，子类只写规则
  # 当前规则：只有 admin 能删评论
  def destroy?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    # 当前列表无需过滤，先返回所有
    def resolve
      scope.all
    end
  end
end
