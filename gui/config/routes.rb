Rails.application.routes.draw do
  root 'leases#index'
  resources :sweepers, only: [:index, :edit, :show, :update, :new, :create, :destroy]
  resources :sweeps, only: [:index, :show]
  resources :nodes, only: [:show]
  resources :devices, only: [:index, :show, :update]
  resources :leases, only: [:show, :index]
  resources :lists, only: [:index, :edit, :show, :update, :new, :create, :destroy]
  resources :fingerprints, only: [:index, :edit, :new, :destroy, :create, :update] 
  get "r2d2" => 'leases#index'
  get "l2s2" => 'sweepers#index'
  constraints subdomain: 'api' do
    namespace :api do #, path: '/'  do
      resources :servers, only: [:index, :update, :show] do
        resources :scopes, only: [:index]
      end
      resources :scopes, only: [:update, :show] do
        resources :leases, only: [:index]
      end
      resources :devices, only: [:show]
      #resources :nodes, only: [:index, :create, :show]
      resources :sweeps, only: [:create]
    end
  end
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
