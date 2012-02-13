
module Argos
  # This module help to externalize the configuration for {Argos::OauthSupport}
  # For determine the properties to load, this module, read the file 
  # config/services.yml in your rails project structure.
  # With the class property called provider load the necessary properties in the 
  # class to access to the remote service.
  #
  # Example:
  #
  # app/model/product.rb
  #
  #   class Product < ActiveResource::Base
  #     extend Argos::OauthSupport
  #     extend Argos::ProviderResolver
  #
  #     self.provider = :inventario
  #
  #   end
  #
  # config/services.yml
  #
  #   development:
  #     inventario:
  #       url: 'http://192.168.1.30:4000'
  #       identifier: '761e2621'
  #       secret: '8740dbce820d968fe4c98a15cf1dd309'
  #     gerencia:
  #       url: 'http://192.168.1.49:3002'
  #       identifier: 'i39x9mq1'
  #       secret: '1340dbce820ds68fe4c9xa15cf1dd3wp'
  #   production
  #     inventario:
  #     
  #
  # This configuration load, in the product class: 
  #   
  #   self.site = 'http://192.168.1.30:4000'
  #   self.oauth_identifier = '761e2621'
  #   self.oauth_secret = '8740dbce820d968fe4c98a15cf1dd309'
  #
  module ProviderResolver

    # Set the provider to search in the file config/services.yml and
    # load the class attributes site, oauth_identifier and oauth_identifier
    #
    # @param [String, Symbol] the name used internally in the file config/services.yml
    # @return [nil]
    def provider=(provider)
      @provider = Argos::Oauth::Applications.by_name(provider)
      self.oauth_identifier = @provider.identifier
      self.oauth_secret = @provider.secret
      self.site = @provider.url
    end

    # @return [Argos::Oauth::Applications, nil] an instance of Argos::Oauth::Applications
    def provider
      @provider
    end
    
  end
end
