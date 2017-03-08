class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :hostname
  before_action :authenticate_if_needed

  def index
  end
  
  def play(last = nil)
    @item = Item.find(:random)
    session[:stats] = { 'cheese' => [0,0], 'font' => [0,0] } unless session[:stats]
  end

  def reset
    session.delete(:stats)
    redirect_to action: 'play'
  end

  def choose
    item = Item.find(params[:id])
    if !item.nil?
      if item.is(params[:guess])
        item.increment!(:correct)
        session[:stats][item.type][0] += 1
        flash[:correct] = play_message(true, item)
      else
        item.increment!(:incorrect)
        session[:stats][item.type][1] += 1
        flash[:incorrect] = play_message(false, item)        
      end
      redirect_to :action => 'play'
    else
      redirect_to :action => 'index'
    end   
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
