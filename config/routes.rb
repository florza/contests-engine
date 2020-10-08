# For details on the DSL available within this file, see:
# http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  # scope path: ApplicationResource.endpoint_namespace, defaults: { format: :jsonapi } do
  scope defaults: { format: :jsonapi } do
    namespace :api do
      namespace :v1 do
        resources :users, only: [:index, :show]
        resources :contests do
          resources :participants
          resources :matches, except: [:create, :destroy]
          resource  :draw, only: [:show, :create, :destroy]
        end
        mount VandalUi::Engine, at: '/vandal'
      end
    end
  end
createdc
  post 'refresh', controller: :refresh, action: :create
  post 'signin', controller: :signin, action: :create
  post 'signup', controller: :signup, action: :create
  delete 'signin', controller: :signin, action: :destroy

  get '*other', to: redirect('/') # show static page in public
end
