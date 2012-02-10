module ActiveResource
  module Oauth
    class Connection < ActiveResource::Connection

      def oauth_identifier=(identifier)
        @oauth_identifier = identifier
      end

      
      def oauth_secret=(secret)
        @oauth_secret = secret
      end

      private 
      
      def http_action(action)
        @@actions ||= { :get    => Net::HTTP::Get,
                        :post   => Net::HTTP::Post,
                        :put    => Net::HTTP::Put,
                        :delete => Net::HTTP::Delete,
                        :head   => Net::HTTP::Head}
        @@actions[action]
      end

      def add_oauth_header(req, path)
        consumer = ::OAuth::Consumer.new(@oauth_identifier, @oauth_secret)
        oauth_helper = ::OAuth::Client::Helper.new(req, {:consumer => consumer, :uri => @site.merge(path).to_s})        
        req["Authorization"] = oauth_helper.header
      end


      def request(method, path, *arguments)
        req = http_action(method).new(path)
        if arguments.size == 2
          # get body and header
          req.body = arguments[0]
          headers = arguments[1]
        else
          headers = arguments[0]
        end
        req.initialize_http_header(headers)
        add_oauth_header(req, path)

        result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
          payload[:method]      = method
          payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"
          #payload[:result]      = http.send(method, path, *arguments)
          payload[:result]      = http.request(req)
        end
        handle_response(result)
        rescue Timeout::Error => e
          raise TimeoutError.new(e.message)
        rescue OpenSSL::SSL::SSLError => e
          raise SSLError.new(e.message)
        end
      end

      
  end
end

