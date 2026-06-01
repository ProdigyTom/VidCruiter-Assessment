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

ActiveRecord::Schema[7.2].define(version: 0) do
  create_table "crew", force: :cascade do |t|
    t.text "title_id"
    t.text "directors"
    t.text "writers"
  end

  create_table "names", id: :text, force: :cascade do |t|
    t.text "primary_name"
    t.integer "birth_year"
    t.integer "death_year"
    t.text "primary_profession"
    t.text "known_for_titles"
  end

  create_table "principals", force: :cascade do |t|
    t.text "title_id"
    t.integer "ordering"
    t.text "name_id"
    t.text "category"
    t.text "job"
    t.text "characters"
  end

  create_table "ratings", force: :cascade do |t|
    t.text "title_id"
    t.float "average_rating"
    t.integer "number_of_votes"
  end

  create_table "titles", id: :text, force: :cascade do |t|
    t.text "primary_title"
    t.text "original_title"
    t.integer "start_year"
    t.integer "runtime"
    t.text "genres"
  end
end
