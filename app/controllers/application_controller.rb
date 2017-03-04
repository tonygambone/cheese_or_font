class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :hostname
  before_action :authenticate_if_needed

  def index
  end
  
  def play(last = nil)
    @item = Item.find(:random)    
  end

  def choose
    item = Item.find(params[:id])
    if !item.nil?          
      game = params[:game] ? Game.find_by_key(params[:game]) : nil
      guess = game ? Guess.new(:item => item, :game => game) : nil
      if item.is(params[:guess])
        item.increment!(:correct)
        if game          
          guess.correct = true
          begin
            guess.save!
          rescue
            # probably a duplicate record            
          end
          flash[:correct] = game_message(true, game, item)
          redirect_to :action => 'game', :key => game.key
        else
          flash[:correct] = play_message(true, item)
          redirect_to :action => 'play'
        end
      else
        item.increment!(:incorrect)
        if game          
          guess.correct = false
          begin
            guess.save!
          rescue
            # probably a duplicate record            
          end
          flash[:incorrect] = game_message(false, game, item)
          redirect_to :action => 'game', :key => game.key
        else        
          flash[:incorrect] = play_message(false, item)
          redirect_to :action => 'play'
        end
      end      
    else
      redirect_to :action => 'index'
    end   
  end
  
  def game    
    @game = params[:key] ? Game.find_by_key(params[:key]) : Game.new
    if @game.new_record?
      while !@game.save
        # handle key collisions by generating a new key
        @game = Game.new
      end
      redirect_to game_path(:key => @game.key)
      return
    end    
    if @game.over?
      redirect_to game_over_path(:key => @game.key)
      return
    end
    @item = @game.next_item
    render :action => 'play'
  end
  
  def game_over
    @game = Game.find_by_key(params[:key], :include => :guesses)
    if !@game
      redirect_to game_path
      return
    elsif !@game.over?
      redirect_to game_path(:key => @game.key)
      return
    elsif @game.final_score.nil?
      counts = @game.counts
      @game.final_score = 100.0 * counts[0] / (counts[0] + counts[1])
      # no longer need to keep the guesses
      @game.guesses.each do |g| g.destroy; end
      @game.save
    end
    completed_games = Game.find(:all, :conditions => "final_score IS NOT NULL", :select => :final_score)
    @avg_score = completed_games.inject(0){|sum,game|sum+game.final_score}.to_f / completed_games.size
    @avg_score = 0.0 if @avg_score.nan?
  end
  
  def stats
    # sorted from hardest -> easiest, with more attempts appearing first for the same ratio
    # also includes 'attempts' and 'ratio' as properties
    items_plus = Item.select("*, correct+incorrect as attempts, 1.0*correct/(correct+incorrect) as ratio").where('correct+incorrect > 0')
    @hardest_items = items_plus.order("ratio ASC, attempts DESC").limit(5)
    # sorted from easiest -> hardest, with more attempts appearing first for the same ratio
    # also includes 'attempts' and 'ratio' as properties
    @easiest_items = items_plus.order("ratio DESC, attempts DESC").limit(5)
    total_select = "'%s' as name, sum(correct) as correct, sum(incorrect) as incorrect, NULL as attempts, NULL as ratio"
    @totals = [
      Item.select(total_select % 'Cheese performance').group(:id).where(cheese: true).first,
      Item.select(total_select % 'Font performance').group(:id).where(cheese: false).first,
      Item.select(total_select % 'Overall performance').group(:id).first]
    @totals.each do |t|
      t.attempts = t.correct + t.incorrect
      t.ratio = t.attempts != 0 ? t.correct.to_f/t.attempts : 0
    end
  end
  
  private
  
  def play_message(is_correct, item)
    '%s %s is a %s. %d%% of people %s.' % 
      [
        is_correct ? 'Correct!' : 'Incorrect!',
        item.name,
        item.cheese? ? "cheese" : "font",
        is_correct ? (1-item.difficulty)*100 : item.difficulty*100,
        is_correct ? 'get that right' : 'get stumped on that'
      ]
  end
  
  def game_message(is_correct, game, item)    
    counts = game.counts
    '%s %s is a %s. Your current score: %d%% with %d remaining.' %
      [
        is_correct ? 'Correct!' : 'Incorrect!',
        item.name,
        item.cheese? ? "cheese" : "font",
        100.0*counts[0]/(counts[0]+counts[1]),
        Item.count - counts[0] - counts[1]
      ]
  end
  
  def hostname
    request.env["SERVER_NAME"]
  end
  
  # if the auth file (config/basic_auth.yml) exists, then do basic HTTP auth,
  # otherwise allow the request. useful to secure test instances, etc.
  # Auth file should be:
  # username: the_username
  # password: the_password
  def authenticate_if_needed
    auth_file = File.join(Rails.root, 'config', 'basic_auth.yml')
    if File.exists? auth_file
      creds = YAML::load(File.open(auth_file))
      authenticate_or_request_with_http_basic do |username, password|
        username == creds["username"] && password == creds["password"]
      end
    else
      true
    end
  end
end
