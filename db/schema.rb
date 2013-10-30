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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "musics", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "version_id", :null => false
    t.integer  "basic_lv",   :null => false
    t.integer  "medium_lv",  :null => false
    t.integer  "hard_lv",    :null => false
    t.date     "added_at",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "players", :force => true do |t|
    t.string   "name",           :limit => 8,  :null => false
    t.string   "pseudonym",                    :null => false
    t.string   "comment",        :limit => 16, :null => false
    t.integer  "team_id"
    t.integer  "play_count",                   :null => false
    t.integer  "stamp",                        :null => false
    t.integer  "onigiri",                      :null => false
    t.datetime "last_play_date",               :null => false
    t.string   "last_play_shop",               :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "scores", :force => true do |t|
    t.integer  "music_id",    :null => false
    t.integer  "scoreset_id", :null => false
    t.integer  "difficulty",  :null => false
    t.float    "achieve",     :null => false
    t.integer  "miss",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "scoresets", :force => true do |t|
    t.integer  "player_id",     :null => false
    t.datetime "registered_at", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "versions", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "released_at", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
