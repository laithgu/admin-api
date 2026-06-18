Rails.application.routes.draw do
  # 健康检查接口
  get "up" => "rails/health#show", as: :rails_health_check

  # API 接口，版本 v1
  namespace :api do
    namespace :v1 do
      # 电影资源的 CRUD（导出走 /downloads 异步队列）
      resources :movies, only: [:index, :show, :destroy] do
        resources :comments, only: [ :index, :create ]
      end
      # 删除评论用独立路由
      resources :comments, only: [ :destroy ]
      # 下载中心
      resources :downloads, only: [ :index, :create ]
      # 用户中心
      resources :users, only: [ :index, :create ]
      # 认证中心
      post "auth/login", to: "auth#login"
      post "auth/logout", to: "auth#logout"
      post "auth/refresh", to: "auth#refresh"
      get  "auth/me", to: "auth#me"
    end
  end
end
