module Argos
  module Oauth

    # Load the configuration of services from the file config/services.yml
    # 
    # Example file:
    #
    #   development:
    #     inventario:
    #       url: 'http://127.0.0.1:3000'
    #       identifier: '761e2621'
    #       secret: '8740dbce820d968fe4c98a15cf1dd309'
    #     ventas:
    #       identifier: 'i39x9mq1'
    #       secret: '1340dbce820ds68fe4c9xa15cf1dd3wp'
    #   test:
    #     inventario:
    #       url: 'http://127.0.0.1:3000'
    #       identifier: '761e2621'
    #       secret: '8740dbce820d968fe4c98a15cf1dd309'
    #
    # This class load to memory the entire file (for the current environment) and provide
    # some methods to obtain the configurations (by_name and by_identifier).
    # Also provide a helper methods to generate a random credentials (random_identifier and random_secure)
    #
    # @note Once loaded the environment, this class don't reload the values if the file change. To do this, you need execute: Argos::Oauth::Applications.reload
    #
    module Applications
      
      @@loaded = false

      # Useful for load new services
      # @return [String] random identifier
      def self.random_identifier
        SecureRandom.hex(4)
      end

      # Return a random secure string
      # Useful for load new services
      # @return [String] random secure string
      def self.random_secure
        SecureRandom.hex(16)
      end
      
      # Find credentials by application name
      # @param [String] name of the application
      # @return [Argos::Oauth::Applications::Credential, nil]
      def self.by_name(name)
        apps_by_name[name]
      end
     
      # Find credentials by identifier token
      # @param [String] identifier token
      # @return [Argos::Oauth::Applications::Credential, nil] nil if not find
      def self.by_identifier(identifier)
        apps_by_identifier[identifier]
      end

      # Read again the file config/services.yml and load the information
      # @return [Boolean] true if can read the file, false if not
      def self.reload
        load_properties(false)
      end

      # Show the information of all credentials
      # @return [String]
      def self.show_credentials
        apps_by_name.values.map { |credential| credential }.join("\n")
      end

      class Credential
        attr_reader :app_name, :identifier, :secret, :url

        def initialize(app_name, identifier, secret, url)
          @app_name = app_name
          @identifier = identifier
          @secret = secret
          @url = url
        end

        def to_s
          "#{app_name}:\n\tIdentifier: #{identifier}\n\tSecret: #{secret}\n\tUrl: #{url}"
        end
      end

      private

      def self.apps_by_name
        load_properties
        @@apps_by_name
      end

      def self.apps_by_identifier
        load_properties
        @@apps_by_identifier
      end

      # Carga los datos obtenidos de config/services.yml
      # El parametro de este método determina si se debe verificar que ya se encuentran cargados los datos. Si
      # se omite o es true, entonces utilizará los datos mas cargados. Si el parámetro es false entonces se
      # vuelven a tomar los datos del archivo.
      def self.load_properties(check_already_load = true)
        return false if check_already_load && @@loaded
        @@apps_by_name, @@apps_by_identifier = {}, {}
        YAML.load_file("#{Rails.root.to_s}/config/services.yml")[Rails.env].each do |app_name, keys|
          credential = Credential.new(app_name, keys['identifier'], keys['secret'], keys['url'])
          @@apps_by_name[credential.app_name] = credential
          @@apps_by_identifier[credential.identifier] = credential
        end 
        @@loaded = true
      end

    end # End class
  end # End module Oauth
end
