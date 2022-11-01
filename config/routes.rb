Trapplar::Application.routes.draw do
  
  root :to => redirect('/index')

  get 'index', to: 'traveling_plans#search', as: "search"
  get 'suggestion' , to: 'traveling_plans#suggestion', as: "suggestion"
  
end
