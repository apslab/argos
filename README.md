= Argos

This gem provides a centralized authentication client (using omniauth and oauth) and REST web service consumtion and exposition, secured by oauth (2 legged).

== Getting started

Add to your rails Gemfile:

  gem 'argos', :git => 'git://github.com/apslab/argos.git'

and then:
  
  bundle 
  rails g argos:install 

this generate:

* The table oauth_nonce
* The configuration file config/initializers/omniauth.rb with the required information of omniauth. Use to communicate with the SSO service.
* The configuration file config/services.yml with the information of the remotes REST web services.

You need to add in your app/controllers/application_controller.rb the following:

  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    
    include Argos::Security

  end

Now you can secure your controllers adding:
  
  before_filter :login_required

== TODO

* Mocking rest consumtion in development environment


This project rocks and uses MIT-LICENSE.
