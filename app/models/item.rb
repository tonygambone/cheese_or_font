class Item < ActiveRecord::Base

  # handle Item.find(:random)
  def self.find(*args)
    if args.first.to_s == "random"
      ids = connection.select_all("SELECT id FROM items")
      super(ids[rand(ids.length)]["id"].to_i)
    else
      super
    end
  end

  # 0 = always correct, 1 = always incorrect
  def difficulty
    1-correct.to_f/(correct+incorrect)
  end

  def font?
    !cheese?
  end

  def is(guess)
    (cheese? && guess.to_s == "cheese") || (font? && guess.to_s == "font")
  end
end
