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

ActiveRecord::Schema[8.1].define(version: 2025_12_18_122522) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "base_rosters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "ends_at", null: false
    t.string "name", null: false
    t.date "starts_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "week_type", default: 0, null: false
    t.index ["user_id"], name: "index_base_rosters_on_user_id"
  end

  create_table "base_shifts", force: :cascade do |t|
    t.bigint "base_roster_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.integer "shift_type", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["base_roster_id"], name: "index_base_shifts_on_base_roster_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.datetime "clock_in"
    t.datetime "clock_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.decimal "hourly_rate", precision: 8, scale: 2, default: "0.0"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 2
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "base_rosters", "users"
  add_foreign_key "base_shifts", "base_rosters"
  add_foreign_key "time_entries", "users"
end
