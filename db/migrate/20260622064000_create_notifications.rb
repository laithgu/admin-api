class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string   :kind,        null: false,             comment: "通知类型 download_completed / download_failed"
      t.string   :title,       null: false
      t.text     :body
      t.string   :target_type, comment: "关联类型 Download / ..."
      t.bigint   :target_id,   comment: "关联ID"
      t.datetime :read_at,     comment: "已读时间，null=未读"

      t.timestamps
    end

    # 按用户及读取时间倒序
    add_index :notifications, [:user_id, :read_at]
    # 关联查询
    add_index :notifications, [:target_type, :target_id]
  end

end
