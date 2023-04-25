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

ActiveRecord::Schema[7.0].define(version: 2023_04_03_081343) do
  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.integer "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_accounts_on_supplier_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.integer "patient_id"
    t.integer "phycisian_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["phycisian_id"], name: "index_appointments_on_phycisian_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "name"
  end

  create_table "books", force: :cascade do |t|
    t.string "name"
    t.string "isbn"
    t.decimal "price", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cars", force: :cascade do |t|
    t.string "name"
  end

  create_table "cars_people", id: false, force: :cascade do |t|
    t.integer "person_id", null: false
    t.integer "car_id", null: false
  end

  create_table "libraries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "novels", force: :cascade do |t|
    t.integer "author_id"
    t.index ["author_id"], name: "index_novels_on_author_id"
  end

  create_table "patients", force: :cascade do |t|
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.index ["email"], name: "unique_emails", unique: true
    t.index ["name"], name: "index_people_on_name"
  end

  create_table "phycisians", force: :cascade do |t|
  end

  create_table "physicians", force: :cascade do |t|
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "part_number"
    t.integer "user_id", null: false
    t.decimal "price", precision: 5, scale: 3
    t.string "supplier_type", null: false
    t.integer "supplier_id", null: false
    t.index ["part_number"], name: "index_products_on_part_number"
    t.index ["supplier_type", "supplier_id"], name: "index_products_on_supplier"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "products_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "product_id", null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "occupation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "novels", "authors"
  add_foreign_key "products", "users"
end
