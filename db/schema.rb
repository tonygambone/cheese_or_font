# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090915133301) do

  create_table "games", :force => true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "final_score", :precision => 4, :scale => 1
  end

  add_index "games", ["key"], :name => "index_games_on_key", :unique => true

  create_table "guesses", :force => true do |t|
    t.integer  "item_id",    :null => false
    t.integer  "game_id",    :null => false
    t.boolean  "correct",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guesses", ["game_id"], :name => "index_guesses_on_game_id"
  add_index "guesses", ["item_id", "game_id"], :name => "index_guesses_on_item_id_and_game_id", :unique => true
  add_index "guesses", ["item_id"], :name => "index_guesses_on_item_id"

  create_table "items", :force => true do |t|
    t.string   "name",                          :null => false
    t.boolean  "cheese",     :default => false, :null => false
    t.integer  "correct",    :default => 0,     :null => false
    t.integer  "incorrect",  :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["name"], :name => "index_items_on_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
