module ActiveResource
  module Oauth
    class Base < ActiveResource::Base

      class << self
        attr_accessor :oauth_identifier, :oauth_secret
      end

      def self.connection(refresh = false)
        if defined?(@connection) || superclass == Object
          @connection = Connection.new(site, format) if refresh || @connection.nil?
          @connection.proxy = proxy if proxy
          @connection.user = user if user
          @connection.password = password if password
          @connection.auth_type = auth_type if auth_type
          @connection.timeout = timeout if timeout
          @connection.ssl_options = ssl_options if ssl_options
          @connection.oauth_secret = oauth_secret if oauth_secret
          @connection.oauth_identifier = oauth_identifier if oauth_identifier
          @connection
        else
          superclass.connection
        end
      end

      private
      
      def self.oauth_identifier
        @oauth_identifier
      end

      def self.oauth_secret
        @oauth_secret
      end

    end
  end
end
