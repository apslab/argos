require 'oauth'
module Argos
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
        @@actions ||= { :get    => { :implementation => Net::HTTP::Get, :body_permitted? => false },
                        :post   => { :implementation => Net::HTTP::Post, :body_permitted? => true },
                        :put    => { :implementation => Net::HTTP::Put, :body_permitted? => true },
                        :delete => { :implementation => Net::HTTP::Delete, :body_permitted? => false },
                        :head   => { :implementation => Net::HTTP::Head, :body_permitted? => false }
                      }
        @@actions[action]
      end

      def add_oauth_header(req, path)
        consumer = ::OAuth::Consumer.new(@oauth_identifier, @oauth_secret)
        oauth_helper = ::OAuth::Client::Helper.new(req, {:consumer => consumer, :uri => @site.merge(path).to_s, :oauth_user_uid => User.current.uid})        
        req["Authorization"] = oauth_helper.header
        puts req["Authorization"]
      end


      def request(method, path, *arguments)
        action = http_action(method)
        path << "?user_uid=#{User.current.uid}" unless action[:body_permitted?]
        req = action[:implementation].new(path)
        if arguments.size == 2
          # get body and header
          puts "body: #{arguments[0]}"
          req.body = arguments[0]
          headers = arguments[1]
        else
          headers = arguments[0]
        end
        req.body << "user_uid=#{User.current.uid}" if action[:body_permitted?]
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

