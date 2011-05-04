Civiccommons::Application.routes.draw do

  # ----------------------------------------
  #   ROUTES README
  # ----------------------------------------
  # * In general routes go from most-to-least specific, top-to-bottom
  # * We use resource routes for all standard routes, including:
  #     :get => [:index, :show, :new, :edit], :post => :create, :put => :update, and :delete => :destroy
  # * We use the :only or :except clauses to exclude all standard routes not in use
  #     e.g. resources :some_controller, only: [:index, :show]
  # * We do not use custom routes to explicitly declare standard routes
  # * We group all custom routes based on the controller
  # * We put resource routes and generic pattern-matching routes after custom routes
  #     e.g. '/some_controller/:id' goes below '/some_controller/some_name'
  # * We use consistent syntax for route mapping
  #     e.g. get '/blah', to: 'bleep#bloop' instead of map '/blah', :to => 'bleep#bloop', :via => :get if possible

  #Application Root
  root to: "homepage#show"

#Custom Matchers

  #authentication
  post '/authentication/decline_fb_auth',              to: 'authentication#decline_fb_auth',                 as: 'decline_fb_auth'
  get  '/authentication/conflicting_email',            to: 'authentication#conflicting_email',               as: 'conflicting_email'
  post '/authentication/conflicting_email',            to: 'authentication#update_conflicting_email',        as: 'update_conflicting_email'
  get   '/authentication/fb_linking_success',          to: 'authentication#fb_linking_success',              as: 'fb_linking_success'
  get   '/authentication/registering_email_taken',     to: 'authentication#registering_email_taken',         as: 'registering_email_taken'
  get   '/authentication/successful_registration',     to: 'authentication#successful_registration',         as: 'successful_registration'
  get   '/authentication/successful_fb_registration',  to: 'authentication#successful_fb_registration',      as: 'successful_fb_registration'
  put   '/authentication/update_account',              to: 'authentication#update_account',                  as: 'auth_update_account'
  get   '/authentication/confirm_facebook_unlinking',  to: 'authentication#confirm_facebook_unlinking',      as: 'confirm_facebook_unlinking'
  get   '/authentication/before_facebook_unlinking',   to: 'authentication#before_facebook_unlinking',       as: 'before_facebook_unlinking'
  delete '/authentication/process_facebook_unlinking', to: 'authentication#process_facebook_unlinking',      as: 'process_facebook_unlinking'

  #Contributions
  post '/contributions/create_confirmed_contribution', to: 'contributions#create_confirmed_contribution',    as: 'create_confirmed_contribution'
  get  '/tos/tos_contribution',                        to: 'tos#tos_contribution',                           as: 'tos_contribution'

  #Conversations
  match '/conversations/preview_node_contribution',    to: 'conversations#preview_node_contribution'
  get '/conversations/node_conversation',              to: 'conversations#node_conversation'
  get '/conversations/new_node_contribution',          to: 'conversations#new_node_contribution'
  get '/conversations/node_permalink/:id',             to: 'conversations#node_permalink'
  put '/conversations/confirm_node_contribution',      to: 'conversations#confirm_node_contribution'
  get '/conversations/responsibilities',               to: 'conversations#responsibilities',                 as: 'conversation_responsibilities'
  get '/conversations/rss',                            to: 'conversations#rss',                              as: 'conversation_rss'
  post '/conversations/toggle_rating',                 to: 'conversations#toggle_rating',                    as: 'conversation_contribution_toggle_rating'
  post 'conversations/blog/:id',                       to: 'conversations#create_from_blog_post',            as: 'start_conversation_from_blog_post'
  post 'conversations/radio/:id',                      to: 'conversations#create_from_radioshow',            as: 'start_conversation_from_radioshow'

  #Subscriptions
  post '/subscriptions/subscribe',                     to: 'subscriptions#subscribe'
  post '/subscriptions/unsubscribe',                   to: 'subscriptions#unsubscribe'

  #UnsubscribeDigest
  get '/unsubscribe-me/:id',                           to: 'unsubscribe_digest#unsubscribe_me',              as: 'unsubscribe_confirmation'
  put '/unsubscribe-me/:id',                           to: 'unsubscribe_digest#remove_from_digest'

  #Community
  get '/community',                                    to: 'community#index',                                as: 'community'

  #Content
  get '/podcast',                                      to: 'radioshow#podcast',                              as: 'podcast'

  #Widget
  get '/widget',                                       to: 'widget#index'

  #Static Pages
  match '/about'             => redirect('/pages/about')
  match '/build_the_commons' => redirect('/pages/build-the-commons')
  match '/careers'           => redirect('/pages/jobs')
  match '/contact_us'        => redirect('/pages/contact')
  match '/faq'               => redirect('/pages/faq')
  match '/feeds'             => redirect('/pages/rss-feeds')
  match '/help'              => redirect('/pages/build-the-commons')
  match '/in-the-news'       => redirect('/news')
  match '/jobs'              => redirect('/pages/jobs')
  match '/partners'          => redirect('/pages/partners')
  match '/poster'            => redirect('/pages/poster')
  match '/posters'           => redirect('/pages/poster')
  match '/press'             => redirect('/news')
  match '/principles'        => redirect('/pages/principles')
  match '/privacy'           => redirect('/pages/privacy')
  match '/radio'             => redirect('/radioshow')
  match '/team'              => redirect('/pages/team')
  match '/terms'             => redirect('/pages/terms')
  match '/volunteer'         => redirect('/pages/build-the-commons')

#Devise Routes
  devise_for :people,
             :controllers => { :registrations => 'registrations', :confirmations => 'confirmations', :sessions => 'sessions', :omniauth_callbacks => "registrations/omniauth_callbacks", :passwords => 'passwords'},
             :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification', :registration => 'register', :sign_up => 'new' }

  devise_scope :person do
    match '/people/ajax_login', :to=>'sessions#ajax_create', :via=>[:post]
    get '/people/secret/fb_auth_forgot_password', to: 'passwords#fb_auth_forgot_password', as: 'fb_auth_forgot_password'
    get "/registrations/omniauth_callbacks/failure", to: "registrations/omniauth_callbacks#failure"
  end

  #Sort and Filters
  constraints FilterConstraint do
    get 'conversations/:filter', to: 'conversations#filter', as: 'conversations_filter'
  end

#Resource Declared Routes
  #Declare genericly-matched GET routes after Filters

  resources :user, only: [:show, :update, :edit] do
    delete "destroy_avatar", on: :member
  end

  resources :issues, only: [:index, :show] do
    post 'create_contribution', on: :member
    resources :pages, controller: :managed_issue_pages, only: [:show]
    resource :vote, controller: :surveys, :type => 'vote'
  end

  resources :conversations, only: [:index, :show, :new, :create] do
    resource :vote, controller: :surveys, :type => 'vote'
    resources :contributions, only: [:edit, :update, :destroy] do
      get '/moderate', to: 'contributions#moderate', on: :member
      put '/moderate', to: 'contributions#moderated', on: :member
    end
  end

  resources :contributions, only: [:destroy]
  resources :regions, only: [:index, :show]
  resources :links, only: [:new, :create]
  resources :invites, only: [:new, :create]
  resources :tos, only: [:new, :create]
  resources :pages, only: [:show]
  resources :blog, only: [:index, :show]
  resources :content, only: [:index, :show]
  resources :news, only: [:index]
  resources :radioshow, only: [:index, :show]

#Namespaces
  namespace "admin" do
    root      to: "dashboard#show"
    resources :articles
    resources :content_items #, only: [:index, :show, :new, :create, :update, :destroy]
    get '/content_items/type/:type', to: 'content_items#index', as: 'content_items_type'
    resources :content_templates
    resources :conversations do
      put 'toggle_staff_pick', on: :member
      put 'update_order', on: :collection
    end
    resources :issues, do
      resources :pages, controller: :managed_issue_pages
      put 'update_order', on: :collection
    end
    get '/issues/pages/all', to: 'managed_issue_pages#all'
    resources :regions
    resources :surveys
    resources :people do
      get 'proxies',       on: :collection
      put 'lock_access',   on: :member
      put 'unlock_access', on: :member
      put 'confirm',       on: :member
    end
    resources :user_registrations, only: [:new, :create]
  end

  namespace "api" do
    get '/:id/conversations',                              to: 'conversations#index',  format: :json
    get '/:id/issues',                                     to: 'issues#index',         format: :json
    get '/:id/contributions',                              to: 'contributions#index',  format: :json
    get '/:id/subscriptions',                              to: 'subscriptions#index',  format: :json
  end

end
