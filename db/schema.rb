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

ActiveRecord::Schema[8.0].define(version: 2026_04_12_051849) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cards", force: :cascade do |t|
    t.text "text", null: false
    t.bigint "user_id", null: false
    t.string "character_code", null: false
    t.string "enemy_code", null: false
    t.integer "position", default: 0
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "copy_count", default: 0
    t.index ["archived_at"], name: "index_cards_on_archived_at"
    t.index ["user_id", "character_code", "enemy_code", "position"], name: "idx_on_user_id_character_code_enemy_code_position_7b616b1da1"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "report_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "card_id", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_report_cards_on_card_id"
    t.index ["user_id"], name: "index_report_cards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login_id", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "refresh_token"
    t.boolean "is_guest", default: false
    t.index ["login_id"], name: "index_users_on_login_id"
  end

  add_foreign_key "cards", "users"
  add_foreign_key "report_cards", "cards"
  add_foreign_key "report_cards", "users"
end
