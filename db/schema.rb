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

ActiveRecord::Schema[8.1].define(version: 2026_03_27_100400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_free", default: false, comment: "Free badge unlockable via achievements"
    t.string "name"
    t.string "rarity", default: "rare", comment: "rare, epic, legendary"
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "experiment_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "experiment_key", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "variant", null: false
    t.index ["user_id", "experiment_key"], name: "index_experiment_assignments_on_user_id_and_experiment_key", unique: true
    t.index ["user_id"], name: "index_experiment_assignments_on_user_id"
  end

  create_table "friend_challenges", force: :cascade do |t|
    t.bigint "challenged_id", null: false
    t.integer "challenged_xp_gain", default: 0, null: false
    t.bigint "challenger_id", null: false
    t.integer "challenger_xp_gain", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.integer "reward_coins", default: 50, null: false
    t.datetime "starts_at", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "winner_id"
    t.index ["challenged_id"], name: "index_friend_challenges_on_challenged_id"
    t.index ["challenger_id", "challenged_id", "status"], name: "index_friend_challenges_on_pair_and_status"
    t.index ["challenger_id"], name: "index_friend_challenges_on_challenger_id"
    t.index ["winner_id"], name: "index_friend_challenges_on_winner_id"
  end

  create_table "friendships", force: :cascade do |t|
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

  create_table "in_app_notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "cta_path"
    t.string "kind", null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "created_at"], name: "index_in_app_notifications_on_user_id_and_created_at"
    t.index ["user_id", "read_at"], name: "index_in_app_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_in_app_notifications_on_user_id"
  end

  create_table "product_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_name", null: false
    t.text "metadata_json", default: "{}", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["event_name", "created_at"], name: "index_product_events_on_event_name_and_created_at"
    t.index ["user_id", "event_name", "created_at"], name: "index_product_events_on_user_id_and_event_name_and_created_at"
    t.index ["user_id"], name: "index_product_events_on_user_id"
  end

  create_table "purchases", force: :cascade do |t|
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

  create_table "quests", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title"
    t.datetime "updated_at", null: false
    t.datetime "valid_until"
    t.integer "xp"
    t.index ["category_id"], name: "index_quests_on_category_id"
  end

  create_table "shop_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "item_type"
    t.string "name"
    t.integer "price_coins"
    t.integer "price_euros"
    t.string "rarity"
    t.datetime "updated_at", null: false
  end

  create_table "user_badges", force: :cascade do |t|
    t.datetime "awarded_at"
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "user_items", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.bigint "shop_item_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["shop_item_id"], name: "index_user_items_on_shop_item_id"
    t.index ["user_id", "shop_item_id"], name: "index_user_items_on_user_id_and_shop_item_id", unique: true
    t.index ["user_id"], name: "index_user_items_on_user_id"
  end

  create_table "user_quests", force: :cascade do |t|
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

  create_table "user_stats", force: :cascade do |t|
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

  create_table "user_weekly_quests", force: :cascade do |t|
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "weekly_quest_id", null: false
    t.index ["user_id"], name: "index_user_weekly_quests_on_user_id"
    t.index ["weekly_quest_id"], name: "index_user_weekly_quests_on_weekly_quest_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "onboarding_completed_at"
    t.text "onboarding_focus", default: "", null: false
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
    t.integer "weekly_streak_count", default: 0, null: false
    t.date "weekly_streak_freeze_used_for_week"
    t.date "weekly_streak_last_completed_on"
    t.integer "xp", default: 0
    t.index ["active_avatar_item_id"], name: "index_users_on_active_avatar_item_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["pseudo"], name: "index_users_on_pseudo", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weekly_quests", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.datetime "valid_until"
    t.integer "xp_reward", default: 300
    t.index ["category_id"], name: "index_weekly_quests_on_category_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "experiment_assignments", "users"
  add_foreign_key "friend_challenges", "users", column: "challenged_id"
  add_foreign_key "friend_challenges", "users", column: "challenger_id"
  add_foreign_key "friend_challenges", "users", column: "winner_id"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "in_app_notifications", "users"
  add_foreign_key "product_events", "users"
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
  add_foreign_key "users", "shop_items", column: "active_avatar_item_id"
  add_foreign_key "weekly_quests", "categories"
end
