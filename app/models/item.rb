class Item < ActiveRecord::Base

  # handle Item.find(:random)
  def self.find(*args)
    if args.first.to_s == "random"
      sql = "SELECT id from items"
      if (args.second)
        if (args.second[:exclude])
          sql << " WHERE id NOT IN (" + args.second[:exclude].join(",") + ")"
        end
      end
      ids = connection.select_all(sql)
      return nil unless !ids.empty?
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

  def type
    cheese? ? "cheese" : "font"
  end
end
