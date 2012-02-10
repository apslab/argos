module ActiveResource
  class Oauth < Base
    def self.connection(refresh = false)
      puts "GREAT!! my connection"
      if defined?(@connection) || superclass == Object
        @connection = Connection.new(site, format) if refresh || @connection.nil?
        @connection.proxy = proxy if proxy
        @connection.user = user if user
        @connection.password = password if password
        @connection.auth_type = auth_type if auth_type
        @connection.timeout = timeout if timeout
        @connection.ssl_options = ssl_options if ssl_options
        @connection
      else
        superclass.connection
      end
    end
  end

end
