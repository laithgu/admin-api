class Download < ApplicationRecord
  validates :name, presence: true
  validates :url, presence: true

  def self.filter_by(params)
    downloads = all

    # 文件名模糊搜索
    if params[:name].present?
      downloads = downloads.where("name ILIKE ?" ,"%#{params[:name]}%")
    end

    if params[:start_date].present?
      downloads = downloads.where("created_at >= ?" , "#{params[:start_date]}")
    end
    if params[:end_date].present?
      downloads = downloads.where("created_at <= ?" , "#{params[:end_date]}")
    end

    downloads.order(id: :desc)
  end
end
