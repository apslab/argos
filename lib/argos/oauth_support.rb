
module Argos
  # This module extend the {http://api.rubyonrails.org/classes/ActiveResource/Base.html ActiveResource::Base} 
  # from rails to support OAuth autentication.
  #
  # You need to set the properties {http://api.rubyonrails.org/classes/ActiveResource/Base.html site}, oauth_identifier and oauth_secret.
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
  # with this configuration already have to use as ActiveResource model normaly
  #
  # For externalize the configuration see {Argos::ProviderResolver}
  #
  module OauthSupport

    attr_accessor :oauth_identifier, :oauth_secret, :requesting_user

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
        @connection.requesting_user_uid = requesting_user.uid if requesting_user
        @connection
      else
        superclass.connection
      end
    end

    private

    def validates_requested_parameters
      unset_parameters = []
      unset_parameters << 'requesting_user' if requesting_user.nil?
      unset_parameters << 'oauth_identifier' if oauth_identifier.nil?
      unset_parameters << 'oauth_secret' if oauth_secret.nil?
      raise "You need to specify the parameters: #{unset_parameters.to_sentence} in the #{self.name} class" unless unset_parameters.empty?
    end

  end
end
