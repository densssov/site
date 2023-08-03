App::Application.routes.draw do
  root 'pages#index'
  resources :pages, only: [:index, :create], path: ""
  get '/add' => 'pages#new', as: :new_page
  get '/*names/add' => 'pages#new', as: :new_subpage
  get '/*names/edit' => 'pages#edit', as: :edit_page
  get '/*names' => 'pages#show', as: :page
  patch '/*names' => 'pages#update', as: :update_page
  post '/*names' => 'pages#create', as: :create_subpage
end
