require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "weblinc"
require "avatax"

module Dummy
  class Application < Rails::Application
    Weblinc.configure do |config|
      config.avatax_default_service_url = 'https://development.avalara.net'
    end
  end
end

