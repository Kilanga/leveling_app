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

ActiveRecord::Schema[8.1].define(version: 2026_03_26_231540) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "public.active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "public.active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "public.active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "public.badges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_free", default: false, comment: "Free badge unlockable via achievements"
    t.string "name"
    t.string "rarity", default: "rare", comment: "rare, epic, legendary"
    t.datetime "updated_at", null: false
  end

  create_table "public.categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "public.friendships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "friend_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friendships_on_user_id"
    t.check_constraint "user_id <> friend_id", name: "friendships_user_not_self"
  end

  create_table "public.purchases", force: :cascade do |t|
    t.integer "amount"
    t.datetime "created_at", null: false
    t.string "item_type"
    t.string "status"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["transaction_id"], name: "index_purchases_on_transaction_id_unique", unique: true, where: "(transaction_id IS NOT NULL)"
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "public.quests", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.boolean "daily_featured", default: false
    t.text "description"
    t.string "title"
    t.datetime "updated_at", null: false
    t.datetime "valid_until"
    t.integer "xp"
    t.index ["category_id"], name: "index_quests_on_category_id"
  end

  create_table "public.shop_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "item_type"
    t.string "name"
    t.integer "price_coins"
    t.integer "price_euros"
    t.string "rarity"
    t.datetime "updated_at", null: false
  end

  create_table "public.user_badges", force: :cascade do |t|
    t.datetime "awarded_at"
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "public.user_items", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.bigint "shop_item_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["shop_item_id"], name: "index_user_items_on_shop_item_id"
    t.index ["user_id", "shop_item_id"], name: "index_user_items_on_user_id_and_shop_item_id", unique: true
    t.index ["user_id"], name: "index_user_items_on_user_id"
  end

  create_table "public.user_quests", force: :cascade do |t|
    t.boolean "active"
    t.boolean "completed"
    t.integer "completed_count", default: 0
    t.datetime "created_at", null: false
    t.integer "progress"
    t.bigint "quest_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["quest_id"], name: "index_user_quests_on_quest_id"
    t.index ["user_id", "quest_id"], name: "index_user_quests_on_user_id_and_quest_id", unique: true
    t.index ["user_id"], name: "index_user_quests_on_user_id"
  end

  create_table "public.user_stats", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "level", default: 1, null: false
    t.integer "total_xp", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "xp", default: 0, null: false
    t.index ["category_id"], name: "index_user_stats_on_category_id"
    t.index ["user_id", "category_id"], name: "index_user_stats_on_user_id_and_category_id", unique: true
    t.index ["user_id"], name: "index_user_stats_on_user_id"
  end

  create_table "public.user_weekly_quests", force: :cascade do |t|
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "weekly_quest_id", null: false
    t.index ["user_id"], name: "index_user_weekly_quests_on_user_id"
    t.index ["weekly_quest_id"], name: "index_user_weekly_quests_on_weekly_quest_id"
  end

  create_table "public.users", force: :cascade do |t|
    t.bigint "active_avatar_item_id"
    t.integer "active_title_id"
    t.boolean "admin", default: false
    t.string "avatar"
    t.datetime "boost_expires_at"
    t.integer "coins", default: 0
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "profile_completed", default: true, null: false
    t.string "provider"
    t.string "pseudo"
    t.datetime "pseudo_last_changed_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.integer "xp", default: 0
    t.index ["active_avatar_item_id"], name: "index_users_on_active_avatar_item_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["pseudo"], name: "index_users_on_pseudo", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "public.weekly_quests", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.datetime "valid_until"
    t.integer "xp_reward", default: 300
    t.index ["category_id"], name: "index_weekly_quests_on_category_id"
  end

  add_foreign_key "public.active_storage_attachments", "public.active_storage_blobs", column: "blob_id"
  add_foreign_key "public.active_storage_variant_records", "public.active_storage_blobs", column: "blob_id"
  add_foreign_key "public.friendships", "public.users"
  add_foreign_key "public.friendships", "public.users", column: "friend_id"
  add_foreign_key "public.purchases", "public.users"
  add_foreign_key "public.quests", "public.categories"
  add_foreign_key "public.user_badges", "public.badges"
  add_foreign_key "public.user_badges", "public.users"
  add_foreign_key "public.user_items", "public.shop_items"
  add_foreign_key "public.user_items", "public.users"
  add_foreign_key "public.user_quests", "public.quests"
  add_foreign_key "public.user_quests", "public.users"
  add_foreign_key "public.user_stats", "public.categories"
  add_foreign_key "public.user_stats", "public.users"
  add_foreign_key "public.user_weekly_quests", "public.users"
  add_foreign_key "public.user_weekly_quests", "public.weekly_quests"
  add_foreign_key "public.users", "public.shop_items", column: "active_avatar_item_id"
  add_foreign_key "public.weekly_quests", "public.categories"

end
