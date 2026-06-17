class AddUserToDownloads < ActiveRecord::Migration[8.1]
  def change
    add_reference :downloads, :user, foreign_key: true
  end
end
