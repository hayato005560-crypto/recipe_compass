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

ActiveRecord::Schema[8.1].define(version: 2026_08_06_062242) do
  create_table "purposes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_purposes_on_name", unique: true
  end

  create_table "recipe_purposes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "purpose_id", null: false
    t.integer "recipe_id", null: false
    t.datetime "updated_at", null: false
    t.index ["purpose_id"], name: "index_recipe_purposes_on_purpose_id"
    t.index ["recipe_id", "purpose_id"], name: "index_recipe_purposes_on_recipe_id_and_purpose_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_purposes_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.text "body"
    t.integer "cooking_time", null: false
    t.datetime "created_at", null: false
    t.text "ingredients", null: false
    t.text "steps", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.text "introduction"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_guest", default: false, null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "recipe_purposes", "purposes"
  add_foreign_key "recipe_purposes", "recipes"
  add_foreign_key "recipes", "users"
  add_foreign_key "sessions", "users"
end
