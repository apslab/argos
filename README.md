# Argos

This gem provides a centralized authentication client (using omniauth and oauth) and REST web service consumtion and exposition, secured by oauth (2 legged).

## Getting started

Add to your rails Gemfile:

    gem 'argos', :git => 'git://github.com/apslab/argos.git'

and then:
  
    bundle 
    rails g argos:install 

this generate:

* The database table oauth_nonce
* The configuration file config/initializers/omniauth.rb with the required information of omniauth. Use to communicate with the SSO service.
* The configuration file config/services.yml with the information of the remotes REST web services.

You need to add in your app/controllers/application_controller.rb the following:

    # app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
    
      include Argos::Security

    end

Now you can secure your controllers adding:
  
    before_filter :login_required

## SSO service configuration

The configuration file config/initializers/omniauth.rb include the url of SSO Service, your (of your application) ID and secret. 
The service work with OAuth (v2) as an strategy of [omniauth](https://github.com/intridea/omniauth).

This implementation require an User model loaded in response to SSO Service.  This model must include the attributes: uid (universal ID), first&#95;name, last&#95;name and email (all as string).  This attributes are loaded when the user sign in currectly.

The Omniauth strategy (APS) used the constant CUSTOM&#95;PROVIDER&#95;URL that can (and should) be loaded in the configuration file. This constant have the url of the SSO service.

File example:

    # config/initializers/omniauth.rb
    CUSTOM_PROVIDER_URL = 'http://localhost:4000'
    APP_ID = '8888651153625cb137f4c7ceb4d7dcd6'
    APP_SECRET = 'c5ce6e753c68222f6d998da605e672e9'

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :aps, APP_ID, APP_SECRET
    end


## External services

The configuration file config/services.yml contains the information of the external services that can be consumed.  

    # config/services.yml
    development:
      inventario:
        url: 'http://127.0.0.1:3000'
        identifier: '761e2621'
        secret: '8740dbce820d968fe4c98a15cf1dd309'
      ventas:
        identifier: 'i39x9mq1'
        secret: '1340dbce820ds68fe4c9xa15cf1dd3wp'
    test:
      inventario:
        url: 'http://127.0.0.1:3000'
        identifier: '761e2621'
        secret: '8740dbce820d968fe4c98a15cf1dd309'


The structure of this file are:

environment &raquo; service_name &raquo; url, identifier and secret

For implement the class that consume this services you use [ActiveResource::Base](http://api.rubyonrails.org/classes/ActiveResource/Base.html) and extend [Argos::OauthSupport](http://rdoc.info/github/apslab/argos/master/Argos/OauthSupport) for supporting OAuth autorization (2 legged).

Example of use:

    class Product < ActiveResource::Base
      extend Argos::OauthSupport

      self.site = 'http://192.168.1.321:3001'
      self.oauth_identifier = '761e2621'
      self.oauth_secret = '8740dbce820d968fe4c98a15cf1dd309'
    end

With this example you configure the service without using the service.yml file.  For use the configuration file you need to extend {Argos::ProviderResolver}

    class Product < ActiveResource::Base
      extend Argos::OauthSupport
      extend Argos::ProviderResolver

      # Provide indicate the service name in the service.yml file
      self.provider = :inventario
    end

The module Argos::OauthSupport add the attribute (not persistent) requesting&#95;user&#95;uid that represent the UID user applicant sended in the request to the remote service.  You need to set this before use the remote model.


For more information you can see [Argos::OauthSupport](http://rdoc.info/github/apslab/argos/master/Argos/OauthSupport) and [Argos::ProviderResolver](http://rdoc.info/github/apslab/argos/master/Argos/ProviderResolver).

You can access to RDoc documentation [here](http://rdoc.info/github/apslab/argos/file/README.md)


This project rocks and uses MIT-LICENSE.
