require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Aps < OmniAuth::Strategies::OAuth2
      option :name, 'aps'

      CUSTOM_PROVIDER_URL = 'http://localhost:4000'

      option :client_options, {
        :site => CUSTOM_PROVIDER_URL,
        :authorize_url => "#{CUSTOM_PROVIDER_URL}/auth/authorize",
        :token_url => "#{CUSTOM_PROVIDER_URL}/auth/access_token"
      }

      uid { raw_info['uid'] }

      info do 
        {
          :first_name => raw_info['info']['first_name'],
          :last_name  => raw_info['info']['last_name'],
          :email      => raw_info['info']['email']
        }
      end

      def raw_info
        @raw_info ||= access_token.get("/auth/user.json?oauth_token=#{access_token.token}").parsed
        #@raw_info ||= access_token.get("/auth/user.json")
      end

    end
  end
end
