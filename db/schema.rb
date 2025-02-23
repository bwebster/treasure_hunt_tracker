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

ActiveRecord::Schema[8.0].define(version: 2025_02_23_134819) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_events_on_date", unique: true
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
    t.boolean "registration", default: false, null: false
    t.index ["event_id", "name"], name: "index_locations_on_event_id_and_name", unique: true
    t.index ["event_id", "number"], name: "index_locations_on_event_id_and_number", unique: true
    t.index ["event_id"], name: "index_locations_on_event_id"
  end

  create_table "rfid_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label", null: false
    t.index ["label"], name: "index_rfid_tags_on_label", unique: true
    t.index ["tag_id"], name: "index_rfid_tags_on_tag_id"
    t.index ["user_id"], name: "index_rfid_tags_on_user_id"
  end

  create_table "scores", id: :string, force: :cascade do |t|
    t.integer "score", null: false
    t.uuid "rfid_tag_id", null: false
    t.string "score_type", null: false
    t.index ["rfid_tag_id"], name: "index_scores_on_rfid_tag_id"
  end

  create_table "tracking_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "rfid_tag_id", null: false
    t.jsonb "metadata"
    t.datetime "scanned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "submitted_location"
    t.uuid "location_id"
    t.index ["location_id"], name: "index_tracking_events_on_location_id"
    t.index ["rfid_tag_id"], name: "index_tracking_events_on_rfid_tag_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "locations", "events"
  add_foreign_key "rfid_tags", "users"
  add_foreign_key "scores", "rfid_tags"
  add_foreign_key "tracking_events", "locations"
  add_foreign_key "tracking_events", "rfid_tags"
end
