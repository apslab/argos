Rails.application.routes.draw do
  scope :module => 'argos' do
    match '/auth/:provider/callback', :to => 'user_session#create'
    match '/auth/failure', :to => 'user_session#failure'
    match '/logout', :to => 'user_session#destroy'
  end
end
