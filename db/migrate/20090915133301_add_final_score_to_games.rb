class AddFinalScoreToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :final_score, :decimal, :precision => 4, :scale => 1
  end

  def self.down
    remove_column :games, :final_score
  end
end
