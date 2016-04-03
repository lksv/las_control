Rails.application.routes.draw do

  mount PdfjsViewer::Rails::Engine => "/pdfjs", as: 'pdfjs'

  as :user do
    post '/user/simple_create' => 'users#create',
      via: :post, as: :user_simple_register
  end
  devise_for :users

  #root to: "about#intro"
  root to: "map#index"

  resources :documents do
    resources :address_blocks
  end
  resources :local_administration_units do
    post 'create_incomming_email',    on: :member
    post 'create_las_admin',          on: :member
    get :options,                     on: :collection
    resources :income_email_addresses
    resources :local_administration_unit_admins
  end
  resources :events do
    get 'tiles',                      on: :collection
  end
  resources :shapes
  resources :notifications
  resources :users, only: :create

  get 'tiles/:z/:x/:y'  =>  'events#tiles', as: :tiles
  get 'public/tiles/:z/:x/:y'  =>  'events#public_tiles', as: :public_tiles

  get 'map', to: 'map#index'

  get 'about' => 'about#index'
  get 'terms' => 'about#terms'


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
