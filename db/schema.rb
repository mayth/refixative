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

ActiveRecord::Schema.define(version: 20140605184224) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "musics", force: true do |t|
    t.integer  "version_id"
    t.string   "name"
    t.integer  "basic_lv"
    t.integer  "medium_lv"
    t.integer  "hard_lv"
    t.integer  "special_lv"
    t.datetime "added_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "musics", ["name"], name: "index_musics_on_name", using: :btree
  add_index "musics", ["version_id"], name: "index_musics_on_version_id", using: :btree

  create_table "players", force: true do |t|
    t.integer  "team_id"
    t.string   "pid"
    t.string   "name"
    t.datetime "last_play_datetime"
    t.string   "last_play_place"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string   "grade"
    t.string   "comment"
    t.integer  "level"
    t.integer  "play_count"
    t.string   "pseudonym"
    t.integer  "refle"
    t.integer  "total_point"
  end

  add_index "players", ["pid"], name: "index_players_on_pid", unique: true, using: :btree
  add_index "players", ["team_id"], name: "index_players_on_team_id", using: :btree

  create_table "records", force: true do |t|
    t.integer  "score_id"
    t.float    "achieve"
    t.integer  "miss"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "records", ["score_id"], name: "index_records_on_score_id", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "player_id"
    t.integer  "music_id"
    t.integer  "difficulty"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "scores", ["music_id"], name: "index_scores_on_music_id", using: :btree
  add_index "scores", ["player_id"], name: "index_scores_on_player_id", using: :btree

  create_table "teams", force: true do |t|
    t.string   "name"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "teams", ["name"], name: "index_teams_on_name", using: :btree

  create_table "versions", force: true do |t|
    t.string   "name"
    t.datetime "released_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "versions", ["name"], name: "index_versions_on_name", using: :btree

end
