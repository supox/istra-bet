Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tournaments, shallow: true do
    resources :rounds, shallow: true do
      resources :rounds, except: :index do
        member do
          get 'bet'
          put 'update_bet'
          get 'calendar'
        end
      end
    end
  end

  root to: 'pages#home'
  get 'pages/home'
end
