# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get '/jozu_gantt' => 'jozu_gantt_settings#index'
get '/projects/:project_id/jozu_gantt' => 'jozu_gantt_settings#project_index'

Rails.application.routes.draw do
  match 'jozu_gantt_settings/:action', :controller => 'jozu_gantt_settings', :via => [:get, :post, :patch, :put]
  match 'projects/:project_id/jozu_gantt_settings/:action', :controller => 'jozu_gantt_settings', :via => [:get, :post, :patch, :put]

  match 'projects/:project_id/issues/jozu_gantt/context_menu', :to => 'jozu_gantt#context_menu', :via => [:get, :post]
  match 'projects/:project_id/jozu_gantt/:action', :controller => 'jozu_gantt', :via => [:get, :post, :patch, :put]
end
