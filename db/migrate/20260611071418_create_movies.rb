class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :name,null: false #电影名称
      t.string :detail_url,null: false #详情链接
      t.string :cover_url #图片链接
      t.decimal :score, precision: 3, scale: 1 #最大三位，保留1位小数
      t.date :published_at #发布时间
      t.integer :duration #时长
      t.text :drama # 简介
      t.string   :categories,   array: true, default: [] #分类
      t.string   :regions,      array: true, default: [] #地区
      t.string :source,null:false,default: "ssr1" #来源
      t.datetime :scraped_at #爬取时间


      t.timestamps
    end
    add_index :movies, :detail_url, unique: true
    add_index :movies, :categories, using: "gin" #针对数组类型查找加的索引
    add_index :movies, :regions,    using: "gin"
  end
end
