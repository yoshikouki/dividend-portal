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

ActiveRecord::Schema.define(version: 2021_07_17_102126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
    t.string "exchange"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "dividends", force: :cascade do |t|
    t.date "ex_dividend_on"
    t.date "records_on"
    t.date "pays_on"
    t.date "declares_on"
    t.string "symbol"
    t.decimal "dividend", precision: 30, scale: 25
    t.decimal "adjusted_dividend", precision: 30, scale: 25
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["symbol"], name: "index_dividends_on_symbol"
  end

  create_table "recent_dividends", force: :cascade do |t|
    t.date "ex_dividend_on"
    t.date "records_on"
    t.date "pays_on"
    t.date "declares_on"
    t.string "symbol"
    t.decimal "dividend", precision: 30, scale: 25
    t.decimal "adjusted_dividend", precision: 30, scale: 25
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["symbol"], name: "index_recent_dividends_on_symbol"
  end

end
