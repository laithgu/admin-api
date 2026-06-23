class Download < ApplicationRecord
  belongs_to :user, optional: true
  # 关联的 Excel 文件，通过 ActiveStorage 传到 OSS
  has_one_attached :file
  enum :status, { pending: 0, completed: 1, failed: 2 }
  validates :name, presence: true
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
