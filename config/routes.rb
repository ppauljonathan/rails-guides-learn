Rails.application.routes.draw do
  get 'employees/index'
  get 'employees/show'
  get 'employees/create'
  get 'employees/update'
  get 'employees/destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :books

  # resources makes all of the below routes
  # get 'books', to: 'books#index'
  # post 'books', to: 'books#create'
  # get 'books/new', to: 'books#new'
  # get 'books/:id', to: 'books#show'
  # get 'books/:id/edit', to: 'books#edit'
  # put 'books/:id', to: 'books#update'
  # patch 'books/:id', to: 'books#update'
  # delete 'books/:id', to: 'books#destroy'

  get 'books/abcd/:id', to: 'books#abcd'
  get 'search', to: 'books#search'

  root "books#index"

  # Defines the root path route ("/")
  # root "articles#index"
end
