module Weblinc
  module Avatax
    include ActiveSupport::Configurable

    class Engine < ::Rails::Engine
      include Weblinc::Plugin

      isolate_namespace Weblinc::Avatax

      Weblinc::Avatax.configure do |config|
        config.valid_service_urls = [
          "https://development.avalara.net",   # development
          "https://avatax.avalara.net"         # production
        ]
      end

      initializer 'weblinc.avatax.templates' do
        Weblinc::Admin.config.views.settings_menu.append(
          'weblinc/admin/menus/avatax_settings'
        )

        Weblinc::Admin.config.views.user_permissions.append(
          'weblinc/admin/users/avatax_settings'
        )
      end

      initializer 'weblinc.avatax.listeners' do
        Weblinc::Publisher.add_listener(Weblinc::Avatax::InvoiceListener.new)
      end
    end
  end
end
