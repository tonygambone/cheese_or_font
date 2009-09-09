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
