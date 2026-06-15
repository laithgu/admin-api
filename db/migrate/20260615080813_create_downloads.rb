class CreateDownloads < ActiveRecord::Migration[8.1]
  def change
    create_table :downloads do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
    add_index :downloads, :name
    add_index :downloads, :created_at
  end
end
