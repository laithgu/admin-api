class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false # 姓名
      t.string :nickname # 昵称
      t.string :avatar # 头像
      t.string :email, null: false # 邮箱
      t.string :password_digest, null: false # 密码
      t.integer :status, null: false, default: 0 # 状态
      t.datetime :deleted_at # 删除时间active: 0, disabled: 1

      t.timestamps
    end
  end
end
