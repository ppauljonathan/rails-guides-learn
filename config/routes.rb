Rails.application.routes.draw do
  get 'employees/index'
  get 'employees/show'
  get 'employees/create'
  get 'employees/update'
  get 'employees/destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :books

  get 'books/abcd/:id', to: 'books#abcd'

  # Defines the root path route ("/")
  # root "articles#index"
end
