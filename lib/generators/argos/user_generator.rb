require 'rails/generators/active_record'

module Argos
  class UserGenerator < Rails::Generators::Base

    include Rails::Generators::Migration    
    extend Argos::MigrationNumberHelper

    source_root File.expand_path('../templates', __FILE__)

    desc 'add the user table'

    def copy_user_migration
      migration_template 'user_migration.rb', 'db/migrate/create_users'
    end

    def copy_user_model
      template 'user.rb', 'app/models/user.rb'
    end

  end

end
