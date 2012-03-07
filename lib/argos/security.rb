require 'active_support/concern'

module Argos
  # Include this module to provide a security methods {#login_required} 
  # and {#current_user}.
  #
  # This methods provide the basic requirements to securing the access to the inherit controllers either by
  # a login user (session) or by rest consume (without session) over oauth.
  #
  # Example of use:
  #
  #   class ApplicationController < ActionController::Base
  #     include Argos::Security
  #
  #   end
  #
  # and use in your own controller
  #
  #   class MyresourceController < ApplicationController
  #     before_filter :login_required
  #
  #   end
  #
  # Beside this, set the current in the context of the actual thread to allow the access in the model context.
  # This is required to send the user in the REST consumtion through ActiveResource::Base with Oauth support ({Argos::OauthSupport}).
  # You can access to the current user through:
  #
  #   User.current
  # 
  module Security

    extend ActiveSupport::Concern

    included do
      around_filter :set_current_user
    end


    # Verifies that the user is logged or, in the case of REST consume from another application without human 
    # intervention, the credentials are correct.  
    # For verify credential this method use {http://tools.ietf.org/html/rfc5849 oauth 1.0}.  Verifying the HTTP 
    # header "Authorization"
    #
    # This method is used as filter in your controllers
    #   before_filter :login_required
    #   
    def login_required
      # if oauth authorization, check oauth
      # else current_user
      if rest_consumption?
        check_oauth_authorization
      else
        check_user_in_session
      end
    end

    # Retrieve the user from session
    # @return [User, nil]
    def current_user
      return nil unless session[:user_uid]
      @current_user ||= User.find_by_uid(session[:user_uid])
    end

    private

    def set_current_user
      User.current = current_user
      begin
        yield
      ensure
        User.current = nil
      end
    end

    def rest_consumption?
      not request.authorization.nil?
    end

    def check_user_in_session
      if current_user.nil?
        respond_to do |format|
          format.html { redirect_to '/auth/aps' }
          format.json { render :json => { 'error' => 'Access Denied' }.to_json, :status => :unauthorized }      
        end
      end
    end
    
    def check_oauth_authorization
      logger.debug('cheking oauth authorization')
      signature = OAuth::Signature.build(Rack::Request.new(env)) do |request_proxy|
        logger.debug("Consumer key: #{request_proxy.consumer_key}")
        secret = Oauth::Applications.by_identifier(request_proxy.consumer_key).try(:secret)
        logger.debug("Secret: #{secret}")
        # return token, secret
        [nil, secret]
      end
      logger.debug("Signature class: #{signature}")
      logger.debug("#signature: #{signature.signature}")
      logger.debug("#request signature: #{signature.request.signature}")
      logger.debug("#verify: #{signature.verify}")
      # http://rubydoc.info/github/oauth/oauth-ruby/master/OAuth/RequestProxy/Base
      logger.debug("signature.request.nonce: #{signature.request.nonce}")
      logger.debug("headers: #{request.headers['user_uid']} #{request.headers['Authorization']}") 
      if signature.verify && Oauth::Nonce.remember(signature.request.nonce, signature.request.timestamp)
        logger.debug("User UID: #{params[:user_uid]}")
        #@current_user = User.first
        # TODO: Reject if not find user?
        session[:user_uid] = User.find_by_uid(params[:user_uid])
      else
        render :json => { 'error' => 'Access Denied' }.to_json, :status => :unauthorized
      end
    end

  end
end
