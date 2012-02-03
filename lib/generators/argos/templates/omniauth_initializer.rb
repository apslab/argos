# Change this omniauth configuration to point to your registered provider
# Since this is a registered application, add the app id and secret here

#require File.expand_path("#{Rails.root}/lib/omniauth/strategies/aps")

CUSTOM_PROVIDER_URL = 'http://localhost:4000'
APP_ID = '8888651153625cb137f4c7ceb4d7dcd6'
APP_SECRET = 'c5ce6e753c68222f6d998da605e672e9'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :aps, APP_ID, APP_SECRET
end
