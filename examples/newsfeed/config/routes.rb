Rails.application.routes.draw do
  # activity
  get 'users/:id/activities' => 'user#activities'
  post 'users/:id/activities' => 'user#new_activity'
  delete 'users/:id/activities/:activity_id' => 'user#hide_activity'
  delete 'activities/:id' => 'activity#remove_activity'

  # related
  post 'users/:id/related' => 'user#new_related'
  delete 'users/:id/related/:related_id' => 'user#remove_related'
end
