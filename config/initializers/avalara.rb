require 'avalara'

Avalara.configure do |config|
  config.username = ENV["AVALARA_USERNAME"] || abort("Avalara missing username.")
  config.password = ENV["AVALARA_PASSWORD"] || abort("Avalara missing password.")
  config.test     = ENV["AVALARA_TEST"]     || true
  #config.version = AVALARA_CONFIGURATION['version'] if AVALARA_CONFIGURATION.has_key?('version')
end
