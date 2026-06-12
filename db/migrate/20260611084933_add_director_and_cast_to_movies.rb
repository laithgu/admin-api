class AddDirectorAndCastToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :director, :string
    add_column :movies, :actors, :string, array: true, default: []


  add_index :movies, :actors,    using: "gin"
  add_index :movies, :score
  add_index :movies, :duration
  add_index :movies, :published_at
  add_index :movies, :director
  end
end
