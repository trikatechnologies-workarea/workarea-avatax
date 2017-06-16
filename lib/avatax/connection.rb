require 'faraday_middleware'

module AvaTax

  module Connection
    private

    def connection
      options = {
        :headers => {
          'Accept' => "application/json; charset=utf-8",
          'User-Agent' => user_agent,
          'Content-Type' => 'application/json'
        },
        :url => endpoint,
        :proxy => proxy,
      }.merge(connection_options)

      c = Faraday::Connection.new(options)
      if logger
        c.response :logger do |logger|
          logger.filter(/(Authorization\:\ \"Basic\ )(\w+)\=/, '\1[REMOVED]')
        end
      end

      c.use Faraday::Response::ParseJson
      c.basic_auth(username, password)

      c
    end
  end
end
