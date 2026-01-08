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

ActiveRecord::Schema[7.1].define(version: 2026_01_02_104708) do
  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.integer "role", default: 1, null: false
    t.integer "branch_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "v_location", limit: 4, comment: "地名"
    t.string "v_code", limit: 3, comment: "分類番号"
    t.string "v_kana", limit: 1, comment: "ひらがな"
    t.string "v_serial", limit: 4, null: false, comment: "一連指定番号"
    t.integer "office_id", null: false, comment: "所属営業所ID"
    t.integer "status_id", default: 1, null: false, comment: "稼働ステータスID"
    t.string "obe_number", limit: 19, comment: "車載器管理番号（OBE）"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["office_id"], name: "index_vehicles_on_office_id"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
    t.index ["v_location", "v_code", "v_kana", "v_serial"], name: "idx_vehicles_full_number"
    t.index ["v_serial"], name: "index_vehicles_on_v_serial"
  end

  add_foreign_key "vehicles", "users"
end
