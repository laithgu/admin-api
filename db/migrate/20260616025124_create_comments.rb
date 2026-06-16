class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :movie, null: false, foreign_key: true # 必填，关联 movies 表
      t.text :content # 评论内容必填
      t.string :author # 评论人必填

      t.timestamps
    end
    # 按时间倒序查询加索引
    add_index :comments, :created_at
  end
end
