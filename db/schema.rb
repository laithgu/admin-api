# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_11_084933) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "movies", force: :cascade do |t|
    t.string "actors", default: [], array: true
    t.string "categories", default: [], array: true
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.string "detail_url", null: false
    t.string "director"
    t.text "drama"
    t.integer "duration"
    t.string "name", null: false
    t.date "published_at"
    t.string "regions", default: [], array: true
    t.decimal "score", precision: 3, scale: 1
    t.datetime "scraped_at"
    t.string "source", default: "ssr1", null: false
    t.datetime "updated_at", null: false
    t.index ["actors"], name: "index_movies_on_actors", using: :gin
    t.index ["categories"], name: "index_movies_on_categories", using: :gin
    t.index ["detail_url"], name: "index_movies_on_detail_url", unique: true
    t.index ["director"], name: "index_movies_on_director"
    t.index ["duration"], name: "index_movies_on_duration"
    t.index ["published_at"], name: "index_movies_on_published_at"
    t.index ["regions"], name: "index_movies_on_regions", using: :gin
    t.index ["score"], name: "index_movies_on_score"
  end
end
