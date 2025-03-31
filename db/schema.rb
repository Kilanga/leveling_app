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

ActiveRecord::Schema[8.0].define(version: 2025_02_20_214112) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "friend_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount"
    t.string "item_type"
    t.string "status"
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "quests", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "xp"
    t.bigint "category_id", null: false
    t.datetime "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "daily_featured", default: false
    t.index ["category_id"], name: "index_quests_on_category_id"
  end

  create_table "shop_items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "rarity"
    t.integer "price_coins"
    t.integer "price_euros"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_type"
  end

  create_table "user_badges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "badge_id", null: false
    t.datetime "awarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "user_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shop_item_id", null: false
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_item_id"], name: "index_user_items_on_shop_item_id"
    t.index ["user_id"], name: "index_user_items_on_user_id"
  end

  create_table "user_quests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "quest_id", null: false
    t.integer "progress"
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "completed_count", default: 0
    t.boolean "active"
    t.index ["quest_id"], name: "index_user_quests_on_quest_id"
    t.index ["user_id"], name: "index_user_quests_on_user_id"
  end

  create_table "user_stats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.integer "level"
    t.integer "xp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_xp"
    t.index ["category_id"], name: "index_user_stats_on_category_id"
    t.index ["user_id"], name: "index_user_stats_on_user_id"
  end

  create_table "user_weekly_quests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "weekly_quest_id", null: false
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_weekly_quests_on_user_id"
    t.index ["weekly_quest_id"], name: "index_user_weekly_quests_on_weekly_quest_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "admin", default: false
    t.integer "xp", default: 0
    t.integer "coins", default: 0
    t.datetime "boost_expires_at"
    t.string "pseudo"
    t.string "avatar"
    t.integer "active_title_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["pseudo"], name: "index_users_on_pseudo", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weekly_quests", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "xp_reward", default: 300
    t.bigint "category_id", null: false
    t.datetime "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_weekly_quests_on_category_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "purchases", "users"
  add_foreign_key "quests", "categories"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "user_badges", "users"
  add_foreign_key "user_items", "shop_items"
  add_foreign_key "user_items", "users"
  add_foreign_key "user_quests", "quests"
  add_foreign_key "user_quests", "users"
  add_foreign_key "user_stats", "categories"
  add_foreign_key "user_stats", "users"
  add_foreign_key "user_weekly_quests", "users"
  add_foreign_key "user_weekly_quests", "weekly_quests"
  add_foreign_key "weekly_quests", "categories"
end
