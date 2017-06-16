require 'faraday'
require File.expand_path('../version', __FILE__)

module AvaTax
  module Configuration

    VALID_OPTIONS_KEYS = [
      :app_name,
      :app_version,
      :machine_name,
      :environment,
      :endpoint,
      :user_agent,
      :username,
      :password,
      :connection_options,
      :logger,
      :proxy,
    ].freeze

    DEFAULT_APP_NAME = nil
    DEFAULT_APP_VERSION = nil
    DEFAULT_MACHINE_NAME = nil
    DEFAULT_ENDPOINT = 'https://rest.avatax.com'
    DEFAULT_USER_AGENT = "AvaTax Ruby Gem #{AvaTax::VERSION}".freeze
    DEFAULT_USERNAME = nil
    DEFAULT_PASSWORD = nil
    DEFAULT_CONNECTION_OPTIONS = {}
    DEFAULT_LOGGER = false
    DEFAULT_PROXY = nil

    attr_accessor *VALID_OPTIONS_KEYS

    # Reset config values when extended
    def self.extended(base)
      base.reset
    end

    # Allow configuration options to be set in a block
    def configure
      yield self
    end

    def options
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    def reset
      self.app_name = DEFAULT_APP_NAME
      self.app_version = DEFAULT_APP_VERSION
      self.machine_name = DEFAULT_MACHINE_NAME
      self.endpoint = DEFAULT_ENDPOINT
      self.user_agent = DEFAULT_USER_AGENT
      self.username = DEFAULT_USERNAME
      self.password = DEFAULT_PASSWORD
      self.connection_options = DEFAULT_CONNECTION_OPTIONS
      self.logger = DEFAULT_LOGGER
      self.proxy = DEFAULT_PROXY
    end

  end
end
