module Argos
  # This module add the current user to the current thread. Thereby can access to current user from the 
  # differents model (not only in the controllers).  
  # This is used to send the current user in the REST consumption.
  #
  # Use in user model as follows:
  #
  #   class User < ActiveRecord::Base
  #     extend ActsAsCurrent
  #   end
  #
  # You can access to current user with:
  #   
  #   User.current
  #
  # Or set the user:
  #
  #   User.current = User.first
  #
  #
  # For set the current user you need to obtain the current user in the ApplicationController. 
  # Example of set the current user:
  #
  #   # app/controller/application_controller.rb
  #
  #   class ApplicationController < ActionController::Base
  #     around_filter :set_current_user
  #
  #     private
  #
  #     def set_current_user
  #       User.current = current_user
  #       begin
  #         yield
  #       ensure
  #         User.current = nil
  #       end
  #     end
  #
  #   end
  #
  # Argos already include a helper to this (see {Argos::Security})
  #
  module ActsAsCurrent
    
    def current=(user)
      Thread.current[:user] = user
    end

    def current
      Thread.current[:user]
    end

  end
end
