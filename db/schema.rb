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

ActiveRecord::Schema.define(version: 2021_09_05_073751) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
    t.string "exchange"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "industry"
    t.string "sector"
    t.string "country"
    t.string "currency"
    t.string "exchange_short_name"
    t.date "ipo_date"
    t.string "image"
    t.integer "years_of_dividend_growth"
    t.index ["symbol"], name: "index_companies_on_symbol"
  end

  create_table "company_tags", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_company_tags_on_company_id"
    t.index ["tag_id"], name: "index_company_tags_on_tag_id"
  end

  create_table "dividends", force: :cascade do |t|
    t.date "ex_dividend_date", null: false
    t.date "record_date"
    t.date "payment_date"
    t.date "declaration_date"
    t.string "symbol"
    t.float "dividend"
    t.float "adjusted_dividend"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "notified", default: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_dividends_on_company_id"
    t.index ["ex_dividend_date", "symbol"], name: "index_dividends_on_ex_dividend_date_and_symbol", unique: true
    t.index ["symbol"], name: "index_dividends_on_symbol"
  end

  create_table "report_queues", force: :cascade do |t|
    t.string "type"
    t.bigint "dividend_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dividend_id"], name: "index_report_queues_on_dividend_id"
  end

  create_table "stock_splits", force: :cascade do |t|
    t.date "date"
    t.string "symbol"
    t.float "numerator"
    t.float "denominator"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["date", "symbol"], name: "index_stock_splits_on_date_and_symbol", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "display_name"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  add_foreign_key "company_tags", "companies"
  add_foreign_key "company_tags", "tags"
  add_foreign_key "dividends", "companies"
  add_foreign_key "report_queues", "dividends"
end
