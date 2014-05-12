RailsApp::Application.routes.draw do
  resources :authentications, only: [:create]
  get '/auth/:provider/callback', to: 'authentications#create'

  resources :unlocks, only: [:show, :new, :create]

  resources :confirmations, only: [:show, :new, :create] do
    get :email,  on: :member
  end

  resource :session, only: [:new, :create, :destroy]

  resources :users

  resources :unlocks, only: [:show, :new, :create,]

  resources :confirmations, only: [:new, :create] do
    get :activate, on: :member
    get :confirm,  on: :member
  end

  root to: 'home#index'

  get 'login' => 'sessions#new', as: :login
  delete 'logout' => 'sessions#destroy', as: :logout

  get 'secret/index'
  get 'secret/not_track'
  get 'secret/not_timeout'
  get 'secret/not_validate_session'

  constraints user_logged_in? do
    get 'a_page', to: 'home#a_page_for_users'
  end

  get 'a_page', to: 'home#a_page_for_visitors'

  constraints current_user{|u| u && u.created_at < 1.year.ago} do
    get 'a_path_constraints_current_user_with_arity_block', to: 'secret#an_action_constraints_current_user_with_arity_block'
  end

  constraints current_user{created_at < 1.year.ago} do
    get 'a_path_constraints_current_user_with_no_arity_block', to: 'secret#an_action_constraints_current_user_with_no_arity_block'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
