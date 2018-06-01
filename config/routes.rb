Rails.application.routes.draw do
  devise_for :users
  resources :tournaments, shallow: true do
    resources :rounds, shallow: true do
      resources :rounds do
        member do
          get 'bet'
          put 'update_bet'
        end 
      end
    end
  end
  root to: 'tournaments#index'

end
