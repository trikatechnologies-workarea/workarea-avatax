module Weblinc
  module Avatax
    include ActiveSupport::Configurable

    class Engine < ::Rails::Engine
      include Weblinc::Plugin

      isolate_namespace Weblinc::Avatax
      initializer 'weblinc.avatax.templates' do
        Weblinc::Admin.config.views.settings_menu.append(
          'weblinc/admin/menus/avatax_settings'
        )
      end
    end
  end
end
