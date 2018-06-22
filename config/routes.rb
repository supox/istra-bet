Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tournaments, shallow: true do
    resources :rounds, shallow: true, except: :index do
      member do
        get 'bet'
        put 'update_bet'
        get 'mail'
        put 'send_mail'
        get 'calendar'
      end
    end
  end

  root to: 'pages#home'
  get 'pages/home'
end
