class MakeItemNameUnique < ActiveRecord::Migration
  def self.up
    add_index :items, :name, :unique => true
  end

  def self.down
    remove_index :items, :name
  end
end
