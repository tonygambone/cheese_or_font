class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :name, :null => false
      t.boolean :cheese, :null => false, :default => false
      t.integer :correct, :null => false, :default => 0
      t.integer :incorrect, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
