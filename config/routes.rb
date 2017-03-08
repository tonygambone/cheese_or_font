Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

root to: 'application#index'
get '/play', to: 'application#play', as: :play
post '/choose', to: 'application#choose', as: :choose
get '/statistics', to: 'application#stats', as: :stats
post '/reset', to: 'application#reset', as: :reset

end
