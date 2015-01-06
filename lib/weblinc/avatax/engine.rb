module Weblinc
  module Avatax
    include ActiveSupport::Configurable

    class Engine < ::Rails::Engine
      include Weblinc::Plugin

      Weblinc::Avatax.configure do |config|
        config.company_code = ENV['AVATAX_COMPANY_CODE']
      end

      isolate_namespace Weblinc::Avatax
    end
  end
end
