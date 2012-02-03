require 'spec_helper'

describe Argos::UserSessionController do

  describe 'routing' do
    it 'routes to /auth/aps/callback' do
      get('/auth/aps/callback').should route_to(:controller => 'argos/user_session', :action => 'create', :provider => 'aps')
    end

    it 'routes to /auth/failure' do
      get('/auth/failure').should route_to(:controller => 'argos/user_session', :action => 'failure')
    end

    it 'routes to /logout' do
      get('/logout').should route_to(:controller => 'argos/user_session', :action => 'destroy')
    end

  end

end
