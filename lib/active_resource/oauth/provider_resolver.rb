module ActiveResource
  module Oauth
    module ProviderResolver

      def provider=(provider)
        @provider = Argos::Oauth::Applications.by_name(provider)
        self.oauth_identifier = @provider.identifier
        self.oauth_secret = @provider.secret
        self.site = @provider.url
      end

      def provider
        @provider
      end
      
    end
  end
end
