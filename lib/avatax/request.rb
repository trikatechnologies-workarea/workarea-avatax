module AvaTax
  module Request

    def get(path, options={})
      request(:get, path, options)
    end

    def post(path, body, options={})
      request(:post, path, options.merge(body: body.to_json))
    end

    def put(path, options={})
      request(:put, path, options)
    end

    def delete(path, options={})
      request(:delete, path, options)
    end

    def request(method, path, options)
      connection.send(method) do |request|
        case method
        when :get, :delete
          request.url(URI.encode(path), options)
        when :post, :put
          request.path = URI.encode(path)
          request.body = options[:body] unless options[:body].empty?
        end
      end
    end
  end
end
