require 'oauth/applications'
require 'rest-client'
# Inherit this class to ease the consume of remote rest resources with {http://tools.ietf.org/html/rfc5849 oauth 1.0} 2 legged support
#
# Example:
#
#   class Product < RestResource
#     provider 'inventario'
#     attr_accessor :id, :name
#   end
#
# The provider indicates the relation with the information of service that consume. This information 
# is contained in the file config/services.yml (see {RestResource.provider})
# The accessor determine what attributes are automatically mapped from the return message from service
#
class RestResource

  def self.find(id)
    return nil if id.nil?
    hash = invoke(:get, "/#{id}")
    initialize_resource(hash)
    rescue RestClient::ResourceNotFound
      raise 'Resource not found'
  end

  def self.all
    hashes = invoke(:get)
    hashes.map { |hash| initialize_resource(hash) }
  end

  # This method set the resource name use to generate the url of the resource rest service.
  # By default the url is formed with the url from the credential and the class name that inherit from
  # RestResource.
  #
  # Example:
  #
  # File config/services.yml
  #
  #   inventario:
  #     url: 'http://192.168.1.1:4000'
  #     identifier: 'xxxxxxx'
  #     secret: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  #
  # resource.rb:
  #
  #   class Resource < RestResource
  #     provider 'inventario'
  #     resource_name 'product'
  #   end
  #
  # The url used to consume the service for class Resource will be: http://192.169.1.1:4000/products
  #
  # item.rb:
  #
  #   class Item < RestResource
  #     provider 'inventario'
  #   end
  #
  # The url used to consume the service for class Item will be: http://192.168.1.1:4000/items
  #
  # @param [String] the resource name used to consume service
  # @return [String] the resource name pluralized. If it was set, they return the previously set value. If not was set, then return the class name pluralized
  #
  def self.resource_name(resource_name = nil)
    @resource_name = resource_name unless resource_name.blank?
    (@resource_name || name).tableize
  end

  # This method set the resource url if you need to change the url provided by provider (see {RestResource.provider}).
  # If you don't pass a parameter, this method return the value set in the class
  #
  # Example:
  #
  #   class Resource < RestResource
  #     resource_url 'http://127.0.0.1:4000/resources'
  #   end
  #
  #   Resource.resource_url                                  # return 'http://127.0.0.1:4000/resources'
  #   Resource.resource_url('http://192.168.1.34/resources') # this set resource_url to 'http://192.168.1.34/resources'
  #   Resource.resource_url                                  # return 'http://192.168.1.34/resources'
  #
  # @param [String] the complete url of the remote resource (with resource path)
  # @return [String] the resource url
  #
  def self.resource_url(resource_url = nil)
    @resource_url = resource_url unless resource_url.blank?
    @resource_url
  end

  # This method set a provider if use a parameter (Ej.: 'inventario') or return, if not use parameter,
  # the Application Credential (Oauth::Applications::Credential).
  # When create a inherited class you require to set this value.
  #
  # Example:
  #
  #   class Resource < RestResource
  #     provider 'inventario'
  #   end
  #
  #   Resource.provider           # returns Oauth::Applications::Credential with app_name 'inventario'
  #   Resource.provider('ventas') # returns Oauth::Applications::Credential with app_name 'provider'
  #   Resource.provider           # returns Oauth::Applications::Credential with app_name 'provider'
  #
  # @param [String] provider name (same loaded in config/services.yml file)
  # @return [Oauth::Applications::Credential] an application credential (see {Oauth::Application::Credential})
  #
  def self.provider(provider = nil)
    @provider = provider.to_s unless provider.blank?
    raise "You must specify the provider in the class #{name}" unless @provider
    Oauth::Applications.by_name(@provider)
  end

  private

  def self.initialize_resource(hash)
    instance = name.constantize.new
    hash.each do |param, value|
      setter_method = "#{param.to_sym}="
      instance.public_send(setter_method, value) if instance.respond_to?(setter_method) 
    end
    instance
  end

  def self.ws_url(extend_path = nil)
    url = resource_url
    if url.nil?
      url = provider.url.clone
      url << "/" unless url.last == "/"
      url << resource_name
    end
    url << extend_path unless extend_path.nil?
    url
  end

  def self.invoke(action, extend_path = nil)
    add_oauth_authorization
    url = ws_url(extend_path)
    response = RestClient.send(action, url, :accept => :json) 
    ActiveSupport::JSON.decode(response.body)
  end

  def self.add_oauth_authorization
    if RestClient.before_execution_procs.empty?
      RestClient.add_before_execution_proc do |req, params|
        #web_service = Oauth::Applications.by_name(provider)
        #consumer = OAuth::Consumer.new(web_service.identifier, web_service.secret)
        consumer = OAuth::Consumer.new(provider.identifier, provider.secret)
        oauth_helper = OAuth::Client::Helper.new(req, {:consumer => consumer, :request_uri => params[:url]})
        req["Authorization"] = oauth_helper.header
      end
    end
  end

end

