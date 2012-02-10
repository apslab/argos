module ActiveResource
  module ConnectionPatching
    puts "My own implementation"
    
    private

    def build_request_headers(headers, http_method, uri)
      puts "YYYYYYYYEAAAAAAAAAAAAAAAAHHH!!!"
      authorization_header(http_method, uri).update(default_header).update(http_format_header(http_method)).update(headers)
    end
  end
end

ActiveResource::Connection.send(:include, ActiveResource::ConnectionPatching)
