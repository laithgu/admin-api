Rails.application.routes.draw do
  # 健康检查接口
  get "up" => "rails/health#show", as: :rails_health_check

  # API 接口，版本 v1
  namespace :api do
    namespace :v1 do
      # 电影资源的 CRUD + 导出
      resources :movies, only: [:index, :show] do
        collection do
          get :export # 导出 Excel
        end
      end
      # 下载中心
      resources :downloads, only: [:index] do
      end
    end
  end
end
