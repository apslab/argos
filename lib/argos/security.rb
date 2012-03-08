
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
  module Security

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

    def set_current_user(user)
      @current_user = user
      session[:user_uid] = user.try(:uid)
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
      signature = OAuth::Signature.build(Rack::Request.new(env)) do |request_proxy|
        secret = Oauth::Applications.by_identifier(request_proxy.consumer_key).try(:secret)
        logger.debug("Consumer key: #{request_proxy.consumer_key}, secret: #{secret}")
        # return token, secret
        [nil, secret]
      end
      logger.debug("calculated signature: #{signature.signature}")
      logger.debug("request signature: #{signature.request.signature}")
      logger.debug("nonce: #{signature.request.nonce}")
      if valid_signature?(signature) && valid_nonce?(signature.request) && valid_user_uid? 
        session[:user_uid] = params[:user_uid]
      else
        render :json => { 'error' => 'Access Denied' }.to_json, :status => :unauthorized
      end
    end

    def valid_signature?(signature)
      signature.verify
    end

    def valid_nonce?(request)
      Oauth::Nonce.remember(request.nonce, request.timestamp)
    end

    def valid_user_uid?
      params.has_key?(:user_uid) && User.exists?(params[:user_uid])
    end

  end
end
