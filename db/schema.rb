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

ActiveRecord::Schema.define(version: 2023_09_09_074012) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", null: false
    t.string "language", default: "en", null: false
    t.boolean "active", default: false, null: false
    t.bigint "author_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_courses_on_author_id"
  end

  create_table "learning_paths", force: :cascade do |t|
    t.bigint "talent_id", null: false
    t.integer "current_position", default: 1
    t.string "progress_status", default: "enrolled", null: false
    t.datetime "started_at"
    t.datetime "paused_at"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["talent_id"], name: "index_learning_paths_on_talent_id"
  end

  create_table "learning_paths_courses", force: :cascade do |t|
    t.bigint "learning_path_id", null: false
    t.bigint "course_id", null: false
    t.string "progress_status", default: "enrolled", null: false
    t.datetime "started_at"
    t.datetime "paused_at"
    t.datetime "completed_at"
    t.integer "position", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_learning_paths_courses_on_course_id"
    t.index ["learning_path_id"], name: "index_learning_paths_courses_on_learning_path_id"
  end

  create_table "talents_courses", force: :cascade do |t|
    t.bigint "talent_id", null: false
    t.bigint "course_id", null: false
    t.string "progress_status", default: "enrolled", null: false
    t.datetime "started_at"
    t.datetime "paused_at"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_talents_courses_on_course_id"
    t.index ["talent_id"], name: "index_talents_courses_on_talent_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "courses", "users", column: "author_id"
  add_foreign_key "learning_paths", "users", column: "talent_id"
  add_foreign_key "talents_courses", "users", column: "talent_id"
end
