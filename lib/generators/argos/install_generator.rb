require 'rails/generators/active_record'

module Argos
  class InstallGenerator < Rails::Generators::Base

    include Rails::Generators::Migration
    extend Argos::MigrationNumberHelper
    
    source_root File.expand_path('../templates', __FILE__)

    desc 'add the oauth_nonce table'

    def copy_oauth_nonce_migration
      migration_template 'migration.rb', 'db/migrate/create_oauth_nonces'
    end
  
    def copy_omniauth_initializer
      template 'omniauth_initializer.rb', 'config/initializers/omniauth.rb'
    end

    def copy_service_yml_config
      template 'services.yml', 'config/services.yml'
    end

#    def add_user_session_controller_routes
#      route "match '/auth/:provider/callback', :to => 'user_session#create', :module => 'argos'"
#      route "match '/auth/failure', :to => 'user_session#failure'"
#      route "match '/logout', :to => 'user_session#destroy'"
#    end

    def show_readme
      readme 'README' if behavior == :invoke
    end

    #def copy_oauth_nonce_model
    #  template 'oauth_nonce.rb', 'app/models/oauth/nonce.rb'
    #end

    #def self.next_migration_number(path)
    #  unless @prev_migration_nr
    #    @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
    #  else
    #    @prev_migration_nr += 1
    #  end
    #  @prev_migration_nr.to_s
    #end
    
  end
end
