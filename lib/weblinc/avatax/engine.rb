module Weblinc
  module Avatax
    include ActiveSupport::Configurable

    class Engine < ::Rails::Engine
      include Weblinc::Plugin

      isolate_namespace Weblinc::Avatax
    end
  end
end
