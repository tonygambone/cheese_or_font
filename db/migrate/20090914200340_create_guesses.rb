class CreateGuesses < ActiveRecord::Migration
  def self.up
    create_table :guesses do |t|
      t.integer :item_id, :null => false
      t.integer :game_id, :null => false
      t.boolean :correct, :null => false
      t.timestamps
    end
    add_index :guesses, :item_id
    add_index :guesses, :game_id
    add_index :guesses, [:item_id, :game_id], :unique => true;
  end

  def self.down
    remove_index :guesses, [:item_id, :game_id]
    remove_index :guesses, :game_id
    remove_index :guesses, :item_id
    drop_table :guesses
  end
end
