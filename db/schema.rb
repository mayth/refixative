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

ActiveRecord::Schema.define(version: 20140109061114) do

  create_table "musics", force: true do |t|
    t.string   "name"
    t.integer  "version_id"
    t.integer  "basic_lv"
    t.integer  "medium_lv"
    t.integer  "hard_lv"
    t.date     "added_at"
    t.date     "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "musics", ["version_id"], name: "index_musics_on_version_id"

  create_table "players", id: false, force: true do |t|
    t.integer  "id",             limit: 6, null: false
    t.string   "name"
    t.string   "pseudonym"
    t.string   "comment"
    t.integer  "team_id"
    t.integer  "play_count"
    t.integer  "stamp"
    t.integer  "onigiri"
    t.datetime "last_play_date"
    t.string   "last_play_shop"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["id"], name: "index_players_on_id", unique: true
  add_index "players", ["team_id"], name: "index_players_on_team_id"

  create_table "records", force: true do |t|
    t.integer  "score_id"
    t.float    "achievement"
    t.integer  "miss_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "records", ["score_id"], name: "index_records_on_score_id"

  create_table "scores", force: true do |t|
    t.integer  "player_id"
    t.integer  "music_id"
    t.integer  "difficulty"
    t.integer  "latest_record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["latest_record_id"], name: "index_scores_on_latest_record_id"
  add_index "scores", ["music_id"], name: "index_scores_on_music_id"
  add_index "scores", ["player_id"], name: "index_scores_on_player_id"

  create_table "teams", id: false, force: true do |t|
    t.integer  "id",         limit: 6
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["id"], name: "index_teams_on_id", unique: true

  create_table "versions", force: true do |t|
    t.string   "name"
    t.date     "released_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
