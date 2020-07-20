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

ActiveRecord::Schema.define(version: 2020_07_18_171217) do

  create_table "contests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", limit: 50, null: false
    t.string "shortname", limit: 20, null: false
    t.text "description", limit: 500, default: "", null: false
    t.string "status", limit: 50, default: "active", null: false
    t.string "contesttype", limit: 50, null: false
    t.integer "nbr_sets", default: 1, null: false
    t.boolean "public", default: false, null: false
    t.string "token_read", limit: 32, null: false
    t.string "token_write", limit: 32, null: false
    t.datetime "last_action_at", default: "2020-07-11 10:25:20", null: false
    t.datetime "draw_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contests_on_user_id"
  end

  create_table "matches", force: :cascade do |t|
    t.integer "contest_id", null: false
    t.integer "participant_1_id"
    t.integer "participant_2_id"
    t.string "status", limit: 10, default: "active", null: false
    t.string "remarks", default: "", null: false
    t.json "userdata"
    t.json "params", default: {}, null: false
    t.datetime "planned_at"
    t.datetime "result_at"
    t.json "result"
    t.integer "winner_id"
    t.integer "looser_id"
    t.integer "winner_next_match_id"
    t.boolean "winner_next_place_1"
    t.integer "looser_next_match_id"
    t.boolean "looser_next_place_1"
    t.integer "updated_by_user_id"
    t.string "updated_by_token", limit: 32
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contest_id"], name: "index_matches_on_contest_id"
    t.index ["looser_next_match_id"], name: "index_matches_on_looser_next_match_id"
    t.index ["participant_1_id"], name: "index_matches_on_participant_1_id"
    t.index ["participant_2_id"], name: "index_matches_on_participant_2_id"
    t.index ["updated_by_user_id"], name: "index_matches_on_updated_by_user_id"
    t.index ["winner_next_match_id"], name: "index_matches_on_winner_next_match_id"
  end

  create_table "participants", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "contest_id", null: false
    t.string "name", limit: 50, null: false
    t.string "shortname", limit: 20, null: false
    t.text "remarks", limit: 500, default: "", null: false
    t.string "status", limit: 10, default: "active", null: false
    t.integer "group", default: 0, null: false
    t.integer "grp_start", default: 0, null: false
    t.integer "grp_pos", default: 0, null: false
    t.integer "ko_tableau", default: 0, null: false
    t.integer "ko_start", default: 0, null: false
    t.integer "ko_pos", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token_write", limit: 32, default: "", null: false
    t.json "group_params", default: {}, null: false
    t.json "ko_params", default: {}, null: false
    t.index ["contest_id", "name"], name: "index_participants_on_contest_and_name", unique: true
    t.index ["contest_id", "shortname"], name: "index_participants_on_contest_and_shortname", unique: true
    t.index ["contest_id"], name: "index_participants_on_contest_id"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
