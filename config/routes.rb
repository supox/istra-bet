Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tournaments, shallow: true do
    member do
      get 'mail'
      put 'send_mail'
    end
    resources :rounds, shallow: true, except: :index do
      member do
        get 'bet'
        put 'update_bet'
        get 'mail'
        put 'send_mail'
        get 'calendar'
        get 'users_bets_csv'
      end
    end
  end

  root to: 'pages#home'
  get 'pages/home'

  get 'settings/unsubscribe'
  patch 'settings/update'

end
