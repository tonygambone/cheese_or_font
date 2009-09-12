# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def index
  end
  
  def play(last = nil)
    @item = Item.find(:random)    
  end

  def choose
    item = Item.find(params[:id])
    if !item.nil?
      if item.is(params[:guess])
        item.increment!(:correct)
        flash[:correct] = message(true, item)
      else
        item.increment!(:incorrect)
        flash[:incorrect] = message(false, item)
      end
      redirect_to :action => 'play'
    else
      redirect_to :action => 'index'
    end   
  end
  
  def stats
    # sorted from hardest -> easiest, with more attempts appearing first for the same ratio
    # also includes 'attempts' and 'ratio' as properties
    @hardest_items = Item.find(:all,
          :select => "*, correct+incorrect as attempts, 1.0*correct/(correct+incorrect) as ratio",
          :conditions => ["incorrect >= 50"],
          :group => "id HAVING ratio >= 0", # :having not available in Rails 2.2.2
          :order => "ratio ASC, attempts DESC",
          :limit => 5)
    # sorted from easiest -> hardest, with more attempts appearing first for the same ratio
    # also includes 'attempts' and 'ratio' as properties
    @easiest_items = Item.find(:all,
          :select => "*, correct+incorrect as attempts, 1.0*correct/(correct+incorrect) as ratio",
          :conditions => ["correct >= 50"],
          :group => "id HAVING ratio >= 0", # :having not available in Rails 2.2.2
          :order => "ratio DESC, attempts DESC",
          :limit => 5)
    total_select = "'%s' as name, sum(correct) as correct, sum(incorrect) as incorrect, NULL as attempts, NULL as ratio"
    @totals = [
      Item.find(:first,:select=>total_select % 'Cheese performance',:conditions=>["cheese = ?", true]),
      Item.find(:first,:select=>total_select % 'Font performance',:conditions=>["cheese = ?", false]),
      Item.find(:first,:select=>total_select % 'Overall performance')]
    @totals.each do |t|
      t.attempts = t.correct + t.incorrect
      t.ratio = t.correct.to_f/t.attempts
    end
  end
  
  private
  
  def message(is_correct, item)
    '%s %s is a %s. %d%% of people %s.' % 
      [
        is_correct ? 'Correct!' : 'Incorrect!',
        item.name,
        item.cheese? ? "cheese" : "font",
        is_correct ? (1-item.difficulty)*100 : item.difficulty*100,
        is_correct ? 'get that right' : 'get stumped on that'
      ]
  end
end
