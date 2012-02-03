module Argos
  #class UserSessionController < OauthRestSecurity.parent_controller.constantize
  class UserSessionController < ::ApplicationController
    def create
      omniauth = request.env['omniauth.auth']
      logger.debug "+++ #{omniauth}"

      user = User.find_by_uid(omniauth['uid'])
      if user.nil?
        params = build_create_user_attributes(omniauth['uid'], omniauth['info'])
        user = User.create!(params)
      else
        user.update_attributes!(omniauth['info'])
      end
      #session[:user_id] = omniauth
      session[:user_uid] = user.uid

      #flash[:notice] = 'Successfully logged in'
      redirect_to root_path
    end

    def build_create_user_attributes(uid, params)
      { :uid => uid,
        :first_name => params['first_name'],
        :last_name => params['last_name'],
        :email => params['email']
      }
    end

    def build_update_user_attributes(uid, params)
      build_update_user_attributes(uid, params).delete(:uid)
    end

    def failure
      flash[:notice] = params[:message]
    end

    def destroy
      session[:user_uid] = nil
      flash[:notice] = 'You have successfully signed out!'
      redirect_to "#{CUSTOM_PROVIDER_URL}/users/sign_out"
    end

  end
end
