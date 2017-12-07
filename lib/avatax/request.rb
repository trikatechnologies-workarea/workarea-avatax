require 'hashie'
require 'json'

module AvaTax
  module Request

    def get(path, options={})
      request(:get, path, nil, options)
    end

    def post(path, model, options={})
      request(:post, path, model, options)
    end

    def put(path, model, options={})
      request(:put, path, model, options)
    end

    def delete(path, options={})
      request(:delete, path, nil, options)
    end

    def request(method, path, model, options={})
      timeout = options.delete(:timeout)

      connection.send(method) do |request|
        request.options.timeout = timeout if timeout
        case method
        when :get, :delete
          request.url("#{URI.encode(path)}?#{URI.encode_www_form(options)}")
        when :post, :put
          request.path = ("#{URI.encode(path)}?#{URI.encode_www_form(options)}")
          request.headers['Content-Type'] = 'application/json'
          request.body = model.to_json unless model.empty?
        end
      end
    end
  end
end
