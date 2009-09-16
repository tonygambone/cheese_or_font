class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.string :key
      t.timestamps
    end
    add_index :games, :key, :unique => :true
  end

  def self.down
    remove_index :games, :key
    drop_table :games
  end
end
