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

ActiveRecord::Schema[8.1].define(version: 2026_01_11_084202) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "award_rates", force: :cascade do |t|
    t.string "award_code"
    t.string "classification"
    t.datetime "created_at", null: false
    t.date "effective_date"
    t.decimal "rate"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_award_rates_on_user_id"
  end

  create_table "base_rosters", force: :cascade do |t|
    t.time "closing_time"
    t.datetime "created_at", null: false
    t.jsonb "daily_budget_allocations", default: {}
    t.date "ends_at", null: false
    t.decimal "estimated_hourly_rate", precision: 8, scale: 2
    t.integer "interval_minutes", default: 30
    t.boolean "is_sales_customized", default: false
    t.boolean "is_wages_customized", default: false
    t.string "name", null: false
    t.time "opening_time"
    t.date "starts_at", null: false
    t.decimal "target_wage_percentage", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "week_type", default: 0, null: false
    t.decimal "weekly_sales_forecast", precision: 10, scale: 2
    t.index ["user_id"], name: "index_base_rosters_on_user_id"
  end

  create_table "base_shifts", force: :cascade do |t|
    t.bigint "base_roster_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.integer "shift_type"
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_section_id"
    t.index ["base_roster_id"], name: "index_base_shifts_on_base_roster_id"
    t.index ["work_section_id"], name: "index_base_shifts_on_work_section_id"
  end

  create_table "sales_forecasts", force: :cascade do |t|
    t.decimal "actual_sales", precision: 8, scale: 2
    t.integer "confidence_level"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.integer "forecast_type"
    t.decimal "projected_sales", precision: 8, scale: 2
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sales_forecasts_on_user_id"
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
    t.string "encrypted_pin"
    t.string "encrypted_pin_iv"
    t.decimal "hourly_rate", precision: 8, scale: 2, default: "0.0"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 2
    t.datetime "updated_at", null: false
    t.integer "wage_percentage_goal", default: 14
    t.decimal "yearly_sales", precision: 12, scale: 2
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weekly_rosters", force: :cascade do |t|
    t.bigint "base_roster_id", null: false
    t.datetime "created_at", null: false
    t.datetime "finalized_at"
    t.bigint "finalized_by_id"
    t.string "name", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.date "week_end_date", null: false
    t.date "week_start_date", null: false
    t.integer "week_type", default: 0, null: false
    t.index ["base_roster_id"], name: "index_weekly_rosters_on_base_roster_id"
    t.index ["finalized_by_id"], name: "index_weekly_rosters_on_finalized_by_id"
    t.index ["user_id"], name: "index_weekly_rosters_on_user_id"
  end

  create_table "weekly_shifts", force: :cascade do |t|
    t.bigint "assigned_staff_id"
    t.time "break_end_time"
    t.time "break_start_time"
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.time "end_time", null: false
    t.integer "shift_type", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.bigint "weekly_roster_id", null: false
    t.index ["assigned_staff_id"], name: "index_weekly_shifts_on_assigned_staff_id"
    t.index ["weekly_roster_id"], name: "index_weekly_shifts_on_weekly_roster_id"
  end

  create_table "work_sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_work_sections_on_user_id"
  end

  add_foreign_key "award_rates", "users"
  add_foreign_key "base_rosters", "users"
  add_foreign_key "base_shifts", "base_rosters"
  add_foreign_key "base_shifts", "work_sections"
  add_foreign_key "sales_forecasts", "users"
  add_foreign_key "time_entries", "users"
  add_foreign_key "weekly_rosters", "users", column: "finalized_by_id"
  add_foreign_key "weekly_shifts", "users", column: "assigned_staff_id"
  add_foreign_key "work_sections", "users"
end
