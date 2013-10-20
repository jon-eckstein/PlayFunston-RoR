# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20131019161026) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "observations", force: true do |t|
    t.text     "obs_date_desc"
    t.string   "condition"
    t.float    "hours_until_next_lowtide"
    t.integer  "condition_code"
    t.float    "wind_mph"
    t.float    "wind_gust_mph"
    t.float    "temp"
    t.float    "wind_chill"
    t.datetime "next_low_tide"
    t.integer  "weather_score"
    t.integer  "tide_score"
    t.boolean  "observed"
    t.integer  "go_funston"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hours_until_next_low_tide_desc"
    t.string   "image_updated_at"
    t.datetime "next_high_tide"
    t.float    "hours_until_next_high_tide"
    t.string   "hours_until_next_high_tide_desc"
  end

end
