
module Argos
  # This module extend the {http://api.rubyonrails.org/classes/ActiveResource/Base.html ActiveResource::Base} 
  # from rails to support OAuth autentication.
  #
  # You need to set the properties {http://api.rubyonrails.org/classes/ActiveResource/Base.html site}, {#oauth_identifier}, 
  # {#oauth_secret} and {#requesting_user_uid} in the model extending this module.
  #
  # Example:
  #
  #   class Product < ActiveResource::Base
  #     extend Argos::OauthSupport
  #
  #     self.site = 'http://192.168.1.321:3001'
  #     self.oauth_identifier = '761e2621'
  #     self.oauth_secret = '8740dbce820d968fe4c98a15cf1dd309'
  #   end
  #
  # with this configuration already have to use as ActiveResource model normaly.
  #
  # Example of use:
  #
  #   Product.requesting_user_uid = current_user.uid  # Set the current user as consumer
  #   p = Product.find(3)                             # retrieve the first product
  #   puts p.id
  #   # 3
  #
  # For externalize the configuration see {Argos::ProviderResolver}
  # 
  # You need to set the uid of the requester user (see {Argos::OauthSupport.requesting_user_uid}). This attribute
  # is required for send to the remote service.
  #
  # @note The class attributes: requesting_user_uid, oauth_identifier and oauth_secret are required.
  #
  module OauthSupport

    attr_accessor :oauth_identifier, :oauth_secret, :requesting_user_uid

    def connection(refresh = false)
      validates_requested_parameters
      if defined?(@connection) || superclass == Object
        @connection = Argos::Oauth::Connection.new(site, format) if refresh || @connection.nil?
        @connection.proxy = proxy if proxy
        @connection.user = user if user
        @connection.password = password if password
        @connection.auth_type = auth_type if auth_type
        @connection.timeout = timeout if timeout
        @connection.ssl_options = ssl_options if ssl_options
        @connection.oauth_secret = oauth_secret if oauth_secret
        @connection.oauth_identifier = oauth_identifier if oauth_identifier
        @connection.requesting_user_uid = requesting_user_uid if requesting_user_uid
        @connection
      else
        superclass.connection
      end
    end

    private

    def validates_requested_parameters
      unset_parameters = []
      unset_parameters << 'requesting_user_uid' if requesting_user_uid.nil?
      unset_parameters << 'oauth_identifier' if oauth_identifier.nil?
      unset_parameters << 'oauth_secret' if oauth_secret.nil?
      raise "You need to specify the parameters: #{unset_parameters.to_sentence} in the #{self.name} class" unless unset_parameters.empty?
    end

  end
end
