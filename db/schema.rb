# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_12_174106) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "poll_id"
    t.integer "points"
    t.string "answer"
    t.boolean "f_love", default: false
    t.boolean "f_funny", default: false
    t.boolean "f_interest", default: false
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_answers_on_poll_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "filters", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_filters_on_category_id"
    t.index ["user_id"], name: "index_filters_on_user_id"
  end

  create_table "friends", force: :cascade do |t|
    t.integer "active_user_id"
    t.integer "follow_user_id"
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "polls", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.integer "t_likes", default: 0
    t.integer "t_love", default: 0
    t.integer "t_funny", default: 0
    t.integer "t_interest", default: 0
    t.integer "points"
    t.string "qtype"
    t.text "question"
    t.string "optype"
    t.text "options", default: [], array: true
    t.string "tags", default: [], array: true
    t.string "image"
    t.datetime "deadline"
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_polls_on_category_id"
    t.index ["user_id"], name: "index_polls_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "poll_id"
    t.string "motive", default: "improper content"
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_reports_on_poll_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "photo"
    t.string "gender"
    t.date "birthdate"
    t.string "location"
    t.string "profession"
    t.string "hobbies"
    t.string "subscription", default: "free"
    t.string "status", default: "active"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "polls"
  add_foreign_key "answers", "users"
  add_foreign_key "filters", "categories"
  add_foreign_key "filters", "users"
  add_foreign_key "polls", "categories"
  add_foreign_key "polls", "users"
  add_foreign_key "reports", "polls"
  add_foreign_key "reports", "users"
end
