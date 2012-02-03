module Security
  def login_required
    # if oauth authorization, check oauth
    # else current_user
    if rest_consumption?
      check_oauth_authorization
    else
      check_user_in_session
    end
  end

  def current_user
    return nil unless session[:user_uid]
    @current_user ||= User.find_by_uid(session[:user_uid])
  end

  private

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
    logger.debug("#verify: #{signature.verify}")
    # http://rubydoc.info/github/oauth/oauth-ruby/master/OAuth/RequestProxy/Base
    logger.debug("signature.request.nonce: #{signature.request.nonce}")
    
    if signature.verify && Oauth::Nonce.remember(signature.request.nonce, signature.request.timestamp)
      # TODO: Ver como enviar el usuario en todas las peticiones.
      #@current_user = User.first
      session[:user_uid] = User.first.uid
    else
      render :json => { 'error' => 'Access Denied' }.to_json, :status => :unauthorized
    end
  end

end
