class Game < ActiveRecord::Base
  validates_presence_of :key
  validates_uniqueness_of :key  
  before_validation {|g| g.key ||= Game::generate_key }
  has_many :guesses
  
  def next_item
    guesses.reload
    if guesses.empty?
      Item.find(:random)
    else
      Item.find(:random, :exclude => guesses.collect{|g|g.item_id})
    end
  end
  
  def next_guess
    Guess.new({:game => self, :item => next_item})
  end
  
  def over?
    !final_score.nil? || next_item.nil?
  end
  
  # returns [correct, incorrect]
  def counts
    a = guesses.reload.group(:correct).count
    [
      a.assoc(true) ? a.assoc(true)[1] : 0,
      a.assoc(false) ? a.assoc(false)[1] : 0
    ]
  end
  
  protected
  
  def self.generate_key
    Digest::MD5.hexdigest("__game__key__" + Time.now.to_s + "__" + rand.to_s)[0,10]
  end
end
